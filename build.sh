#!/bin/bash

# --- Configurações do AnyKernel3 ---
AK3_DIR="$(pwd)/AnyKernel3"
OUT_DIR="$(pwd)/out"
FINAL_ZIP_DIR="$(pwd)/build/out"

abort()
{
    echo "-----------------------------------------------"
    echo "Erro na compilação! Abortando..."
    echo "-----------------------------------------------"
    exit -1
}

unset_flags()
{
    echo "Usage: $(basename "$0") -m [modelo] -k [y/N]"
    echo "Exemplo: ./build.sh -m x1s -k y"
}

# --- Parse de Argumentos ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --model|-m) MODEL="$2"; shift 2 ;;
        --ksu|-k) KSU_OPTION="$2"; shift 2 ;;
        *) unset_flags; exit 1 ;;
    esac
done

if [ -z "$MODEL" ]; then unset_flags; exit 1; fi

# --- Ambiente de Build ---
CORES=$(nproc --all)
CLANG_DIR="$(pwd)/toolchain/clang_14"
export PATH="$CLANG_DIR/bin:$PATH"

# Download Toolchain se não existir
if [ ! -f "$CLANG_DIR/bin/clang" ]; then
    echo "Baixando Toolchain..."
    mkdir -p $CLANG_DIR
    curl -Lo clang.tar.gz https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-13.0.0_r13/clang-r450784d.tar.gz
    tar -xf clang.tar.gz -C $CLANG_DIR
    rm clang.tar.gz
fi

# --- Comandos de Compilação ---
MAKE_ARGS="
LLVM=1 \
LLVM_IAS=1 \
ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CROSS_COMPILE_COMPAT=arm-linux-gnueabi- \
O=out
"

echo "-----------------------------------------------"
echo "Compilando para o modelo: $MODEL"
echo "KernelSU: ${KSU_OPTION:-n}"
echo "-----------------------------------------------"

# Configuração de Kernelsu
KSU_CONFIG=""
if [[ "$KSU_OPTION" == "y" ]]; then
    KSU_CONFIG="ksu.config"
fi

# 1. Gerar Defconfig (Base Exynos + Spec do Modelo + KSU)
make ${MAKE_ARGS} exynos9830_defconfig $MODEL.config $KSU_CONFIG || abort

# 2. Compilar Kernel e DTBs
make ${MAKE_ARGS} -j$CORES || abort

# --- Integração com AnyKernel3 ---
echo "-----------------------------------------------"
echo "Preparando pacote AnyKernel3..."
echo "-----------------------------------------------"

# Limpeza prévia
rm -rf "$AK3_DIR/Image" "$AK3_DIR/dtb" "$AK3_DIR/dtbo.img"

# Copiar arquivos gerados
cp "$OUT_DIR/arch/arm64/boot/Image" "$AK3_DIR/"
cp "$OUT_DIR/arch/arm64/boot/dts/exynos/exynos9830.dtb" "$AK3_DIR/dtb" 
# Se o seu modelo exigir dtbo específica:
# cp "$OUT_DIR/arch/arm64/boot/dts/samsung/$MODEL.dtbo" "$AK3_DIR/dtbo.img"

# Gerar o ZIP
mkdir -p "$FINAL_ZIP_DIR/$MODEL"
pushd "$AK3_DIR" > /dev/null
DATE=$(date +"%d%m%Y_%H%M")
ZIP_NAME="LoungeAct-${MODEL}-${DATE}.zip"

# Compacta tudo exceto arquivos de controle do git
zip -r9 "$FINAL_ZIP_DIR/$MODEL/$ZIP_NAME" ./* -x .git* README.md *placeholder
popd > /dev/null

echo "-----------------------------------------------"
echo "BUILD FINALIZADO COM SUCESSO!"
echo "Arquivo: $FINAL_ZIP_DIR/$MODEL/$ZIP_NAME"
echo "-----------------------------------------------"
