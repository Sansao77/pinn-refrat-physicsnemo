ARG RELEASE
ARG LAUNCHPAD_BUILD_ARCH

LABEL org.opencontainers.image.version=24.04

ADD file:8c609c85109d07bf47cf268a175b3be8bbe34fc0c41d15d99b090d099f4dc837 in /

CMD ["/bin/bash"]
SHELL [/bin/bash -c]
ARG ENABLE_MITMPROXY=0

RUN |1 ENABLE_MITMPROXY=0 /bin/bash -c /tmp/manage_cert.sh install # buildkit

RUN |1 ENABLE_MITMPROXY=0 /bin/bash -c if [ -d /usr/share/ca-certificates ]; then exit; fi && export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/* # buildkit

RUN |1 ENABLE_MITMPROXY=0 /bin/bash -c /tmp/manage_cert.sh install # buildkit

RUN |1 ENABLE_MITMPROXY=0 /bin/bash -c export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y --no-install-recommends adduser curl libnl-route-3-200 libnl-3-200 libnl-3-dev libnl-route-3-dev patch wget && rm -rf /var/lib/apt/lists/* && echo "hsts=0" > /root/.wgetrc # buildkit

ARG GDRCOPY_VERSION=2.5.1
ARG HPCX_VERSION=2.50
ARG RDMACORE_VERSION=63.0
ARG MOFED_VERSION=5.4-rdmacore63.0
ARG OPENUCX_VERSION=1.21.0
ARG OPENMPI_VERSION=5.0.10
ARG EFA_VERSION=1.48.0

ENV GDRCOPY_VERSION=2.5.1 HPCX_VERSION=2.50 MOFED_VERSION=5.4-rdmacore63.0 OPENUCX_VERSION=1.21.0 OPENMPI_VERSION=5.0.10 RDMACORE_VERSION=63.0 EFA_VERSION=1.48.0 NCCL_NET_PLUGIN=spcx
ARG TARGETARCH=amd64

RUN |9 ENABLE_MITMPROXY=0 GDRCOPY_VERSION=2.5.1 HPCX_VERSION=2.50 RDMACORE_VERSION=63.0 MOFED_VERSION=5.4-rdmacore63.0 OPENUCX_VERSION=1.21.0 OPENMPI_VERSION=5.0.10 EFA_VERSION=1.48.0 TARGETARCH=amd64 /bin/bash -c cd /nvidia && export OPENMPI_VERSION_MAJOR="${OPENMPI_VERSION%%.*}" && echo "OPENMPI_VERSION_MAJOR: ${OPENMPI_VERSION_MAJOR}" && ( cd opt/rdma-core/ && dpkg -i libibverbs1_*.deb libibverbs-dev_*.deb librdmacm1_*.deb librdmacm-dev_*.deb libibumad3_*.deb libibumad-dev_*.deb ibverbs-utils_*.deb ibverbs-providers_*.deb && rm $(dpkg-query -L libibverbs-dev librdmacm-dev libibumad-dev | grep "\(\.a\)$") ) && ( cd opt/gdrcopy/ && dpkg -i libgdrapi_*.deb ) && ( cp -r opt/hpcx /opt/ && cp etc/ld.so.conf.d/hpcx.conf /etc/ld.so.conf.d/ && ln -sf /opt/hpcx/ompi${OPENMPI_VERSION_MAJOR} /usr/local/mpi && ln -sf /opt/hpcx/ucx /usr/local/ucx && sed -i 's/^\(hwloc_base_binding_policy\) = core$/\1 = none/' /opt/hpcx/ompi${OPENMPI_VERSION_MAJOR}/etc/openmpi-mca-params.conf && sed -i 's/^\(btl = self\)$/#\1/' /opt/hpcx/ompi${OPENMPI_VERSION_MAJOR}/etc/openmpi-mca-params.conf ) && ldconfig # buildkit

ENV OPAL_PREFIX=/usr/local/mpi PATH=/usr/local/mpi/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/ucx/bin:/opt/amazon/efa/bin

ENV OMPI_MCA_coll_hcoll_enable=0

ARG CUDA_VERSION=13.3.1.008

ARG CUDA_DRIVER_VERSION=610.43.02

ARG NVVM_VERSION=13.3.73

ARG DOCA_VERSION=3.4.0

ENV CUDA_VERSION=13.3.1.008 CUDA_DRIVER_VERSION=610.43.02 NVVM_VERSION=13.3.73 DOCA_VERSION=3.4.0

RUN |13 ENABLE_MITMPROXY=0 GDRCOPY_VERSION=2.5.1 HPCX_VERSION=2.50 RDMACORE_VERSION=63.0 MOFED_VERSION=5.4-rdmacore63.0 OPENUCX_VERSION=1.21.0 OPENMPI_VERSION=5.0.10 EFA_VERSION=1.48.0 TARGETARCH=amd64 CUDA_VERSION=13.3.1.008 CUDA_DRIVER_VERSION=610.43.02 NVVM_VERSION=13.3.73 DOCA_VERSION=3.4.0 /bin/bash -c export ARTIFACTORY_USER=$(cat /run/secrets/ARTIFACTORY_USER) && export ARTIFACTORY_TOKEN=$(cat /run/secrets/ARTIFACTORY_TOKEN) && BASE=min /nvidia/build-scripts/installCUDA.sh # buildkit

RUN |13 ENABLE_MITMPROXY=0 GDRCOPY_VERSION=2.5.1 HPCX_VERSION=2.50 RDMACORE_VERSION=63.0 MOFED_VERSION=5.4-rdmacore63.0 OPENUCX_VERSION=1.21.0 OPENMPI_VERSION=5.0.10 EFA_VERSION=1.48.0 TARGETARCH=amd64 CUDA_VERSION=13.3.1.008 CUDA_DRIVER_VERSION=610.43.02 NVVM_VERSION=13.3.73 DOCA_VERSION=3.4.0 /bin/bash -c cp -vprd /nvidia/. / && patch -p0 < /etc/startup_scripts.patch && rm -f /etc/startup_scripts.patch # buildkit

ENV _CUDA_COMPAT_PATH=/usr/local/cuda/compat ENV=/etc/shinit_v2 BASH_ENV=/etc/bash.bashrc SHELL=/bin/bash NVIDIA_REQUIRE_CUDA=cuda>=9.0

LABEL com.nvidia.volumes.needed=nvidia_driver com.nvidia.cuda.version=9.0

ARG NCCL_VERSION=2.30.7 CCCL_VERSION=13.3.3.4.1 CUBLAS_VERSION=13.6.0.2 CUFFT_VERSION=12.3.0.29 CURAND_VERSION=10.4.3.29 CUSPARSE_VERSION=12.8.2.51 CUSOLVER_VERSION=12.2.6.9 NPP_VERSION=13.1.2.81 NVJPEG_VERSION=13.2.1.68 CUFILE_VERSION=1.18.1.6 NVJITLINK_VERSION=13.3.33 NVFATBIN_VERSION=13.3.29 CUBLASMP_VERSION=0.9.1.3056 CUSOLVERMP_VERSION=0.8.0.3126 NVSHMEM_VERSION=3.7.1 CUDLA_VERSION=13.3.29 NVPTXCOMPILER_VERSION=13.3.73 CUDNN_VERSION=9.24.0.43 CUDNN_FRONTEND_VERSION=1.25.0 TRT_VERSION=11.1.0.106 TRTOSS_VERSION= NSIGHT_SYSTEMS_VERSION=2026.3.1.117 NSIGHT_COMPUTE_VERSION=2026.2.1.5 CUSPARSELT_VERSION=0.9.1.1 DALI_VERSION=2.2.0 DALI_BUILD= DALI_URL_SUFFIX=130 POLYGRAPHY_VERSION=0.50.3 TRANSFORMER_ENGINE_VERSION=2.17 MODEL_OPT_VERSION=0.44.0 CUDA_ARCH_LIST=7.5 8.0 8.6 9.0 10.0 12.0 MAXSMVER= NVRX_VERSION=0.6.0 NIXL_VERSION=1.3.0 CUTILE_PYTHON_VERSION=1.4.0 CUTLASS_DSL_VERSION=4.5.2

ENV NCCL_VERSION=2.30.7 CCCL_VERSION=13.3.3.4.1 CUBLAS_VERSION=13.6.0.2 CUFFT_VERSION=12.3.0.29 CURAND_VERSION=10.4.3.29 CUSPARSE_VERSION=12.8.2.51 CUSPARSELT_VERSION=0.9.1.1 CUSOLVER_VERSION=12.2.6.9 NPP_VERSION=13.1.2.81 NVJPEG_VERSION=13.2.1.68 CUFILE_VERSION=1.18.1.6 NVJITLINK_VERSION=13.3.33 NVFATBIN_VERSION=13.3.29 CUBLASMP_VERSION=0.9.1.3056 CUSOLVERMP_VERSION=0.8.0.3126 NVSHMEM_VERSION=3.7.1 CUDLA_VERSION=13.3.29 NVPTXCOMPILER_VERSION=13.3.73 CUDNN_VERSION=9.24.0.43 CUDNN_FRONTEND_VERSION=1.25.0 TRT_VERSION=11.1.0.106 TRTOSS_VERSION= NSIGHT_SYSTEMS_VERSION=2026.3.1.117 NSIGHT_COMPUTE_VERSION=2026.2.1.5 DALI_VERSION=2.2.0 DALI_BUILD= DALI_URL_SUFFIX=130 POLYGRAPHY_VERSION=0.50.3 TRANSFORMER_ENGINE_VERSION=2.17 MODEL_OPT_VERSION=0.44.0 CUDA_ARCH_LIST=7.5 8.0 8.6 9.0 10.0 12.0 MAXSMVER= NVRX_VERSION=0.6.0 NIXL_VERSION=1.3.0 CUTILE_PYTHON_VERSION=1.4.0 CUTLASS_DSL_VERSION=4.5.2

ADD docs.tgz / # buildkit

RUN |49 ENABLE_MITMPROXY=0 GDRCOPY_VERSION=2.5.1 HPCX_VERSION=2.50 RDMACORE_VERSION=63.0 MOFED_VERSION=5.4-rdmacore63.0 OPENUCX_VERSION=1.21.0 OPENMPI_VERSION=5.0.10 EFA_VERSION=1.48.0 TARGETARCH=amd64 CUDA_VERSION=13.3.1.008 CUDA_DRIVER_VERSION=610.43.02 NVVM_VERSION=13.3.73 DOCA_VERSION=3.4.0 NCCL_VERSION=2.30.7 CCCL_VERSION=13.3.3.4.1 CUBLAS_VERSION=13.6.0.2 CUFFT_VERSION=12.3.0.29 CURAND_VERSION=10.4.3.29 CUSPARSE_VERSION=12.8.2.51 CUSOLVER_VERSION=12.2.6.9 NPP_VERSION=13.1.2.81 NVJPEG_VERSION=13.2.1.68 CUFILE_VERSION=1.18.1.6 NVJITLINK_VERSION=13.3.33 NVFATBIN_VERSION=13.3.29 CUBLASMP_VERSION=0.9.1.3056 CUSOLVERMP_VERSION=0.8.0.3126 NVSHMEM_VERSION=3.7.1 CUDLA_VERSION=13.3.29 NVPTXCOMPILER_VERSION=13.3.73 CUDNN_VERSION=9.24.0.43 CUDNN_FRONTEND_VERSION=1.25.0 TRT_VERSION=11.1.0.106 TRTOSS_VERSION= NSIGHT_SYSTEMS_VERSION=2026.3.1.117 NSIGHT_COMPUTE_VERSION=2026.2.1.5 CUSPARSELT_VERSION=0.9.1.1 DALI_VERSION=2.2.0 DALI_BUILD= DALI_URL_SUFFIX=130 POLYGRAPHY_VERSION=0.50.3 TRANSFORMER_ENGINE_VERSION=2.17 MODEL_OPT_VERSION=0.44.0 CUDA_ARCH_LIST=7.5 8.0 8.6 9.0 10.0 12.0 MAXSMVER= NVRX_VERSION=0.6.0 NIXL_VERSION=1.3.0 CUTILE_PYTHON_VERSION=1.4.0 CUTLASS_DSL_VERSION=4.5.2 /bin/bash -c echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf && if [ "${TARGETARCH}" = "arm64" ]; then echo "/usr/lib/aarch64-linux-gnu/tegra" >> /etc/ld.so.conf.d/nvidia.conf && echo "/usr/lib/aarch64-linux-gnu/tegra-egl" >> /etc/ld.so.conf.d/nvidia.conf; fi # buildkit

ARG _LIBPATH_SUFFIX=

ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/mpi/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/ucx/bin:/opt/amazon/efa/bin LD_LIBRARY_PATH=/usr/local/cuda/compat/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64 NVIDIA_VISIBLE_DEVICES=all NVIDIA_DRIVER_CAPABILITIES=compute,utility,video

RUN |50 ENABLE_MITMPROXY=0 GDRCOPY_VERSION=2.5.1 HPCX_VERSION=2.50 RDMACORE_VERSION=63.0 MOFED_VERSION=5.4-rdmacore63.0 OPENUCX_VERSION=1.21.0 OPENMPI_VERSION=5.0.10 EFA_VERSION=1.48.0 TARGETARCH=amd64 CUDA_VERSION=13.3.1.008 CUDA_DRIVER_VERSION=610.43.02 NVVM_VERSION=13.3.73 DOCA_VERSION=3.4.0 NCCL_VERSION=2.30.7 CCCL_VERSION=13.3.3.4.1 CUBLAS_VERSION=13.6.0.2 CUFFT_VERSION=12.3.0.29 CURAND_VERSION=10.4.3.29 CUSPARSE_VERSION=12.8.2.51 CUSOLVER_VERSION=12.2.6.9 NPP_VERSION=13.1.2.81 NVJPEG_VERSION=13.2.1.68 CUFILE_VERSION=1.18.1.6 NVJITLINK_VERSION=13.3.33 NVFATBIN_VERSION=13.3.29 CUBLASMP_VERSION=0.9.1.3056 CUSOLVERMP_VERSION=0.8.0.3126 NVSHMEM_VERSION=3.7.1 CUDLA_VERSION=13.3.29 NVPTXCOMPILER_VERSION=13.3.73 CUDNN_VERSION=9.24.0.43 CUDNN_FRONTEND_VERSION=1.25.0 TRT_VERSION=11.1.0.106 TRTOSS_VERSION= NSIGHT_SYSTEMS_VERSION=2026.3.1.117 NSIGHT_COMPUTE_VERSION=2026.2.1.5 CUSPARSELT_VERSION=0.9.1.1 DALI_VERSION=2.2.0 DALI_BUILD= DALI_URL_SUFFIX=130 POLYGRAPHY_VERSION=0.50.3 TRANSFORMER_ENGINE_VERSION=2.17 MODEL_OPT_VERSION=0.44.0 CUDA_ARCH_LIST=7.5 8.0 8.6 9.0 10.0 12.0 MAXSMVER= NVRX_VERSION=0.6.0 NIXL_VERSION=1.3.0 CUTILE_PYTHON_VERSION=1.4.0 CUTLASS_DSL_VERSION=4.5.2 _LIBPATH_SUFFIX= /bin/bash -c export ARTIFACTORY_USER=$(cat /run/secrets/ARTIFACTORY_USER) && export ARTIFACTORY_TOKEN=$(cat /run/secrets/ARTIFACTORY_TOKEN) && if [ -n "${DOCA_VERSION}" ] && dpkg --compare-versions "${HPCX_VERSION}" "ge" "2.24"; then /nvidia/build-scripts/installDOCA.sh; else echo "Not running installDOCA.sh"; fi # buildkit

RUN |50 ENABLE_MITMPROXY=0 GDRCOPY_VERSION=2.5.1 HPCX_VERSION=2.50 RDMACORE_VERSION=63.0 MOFED_VERSION=5.4-rdmacore63.0 OPENUCX_VERSION=1.21.0 OPENMPI_VERSION=5.0.10 EFA_VERSION=1.48.0 TARGETARCH=amd64 CUDA_VERSION=13.3.1.008 CUDA_DRIVER_VERSION=610.43.02 NVVM_VERSION=13.3.73 DOCA_VERSION=3.4.0 NCCL_VERSION=2.30.7 CCCL_VERSION=13.3.3.4.1 CUBLAS_VERSION=13.6.0.2 CUFFT_VERSION=12.3.0.29 CURAND_VERSION=10.4.3.29 CUSPARSE_VERSION=12.8.2.51 CUSOLVER_VERSION=12.2.6.9 NPP_VERSION=13.1.2.81 NVJPEG_VERSION=13.2.1.68 CUFILE_VERSION=1.18.1.6 NVJITLINK_VERSION=13.3.33 NVFATBIN_VERSION=13.3.29 CUBLASMP_VERSION=0.9.1.3056 CUSOLVERMP_VERSION=0.8.0.3126 NVSHMEM_VERSION=3.7.1 CUDLA_VERSION=13.3.29 NVPTXCOMPILER_VERSION=13.3.73 CUDNN_VERSION=9.24.0.43 CUDNN_FRONTEND_VERSION=1.25.0 TRT_VERSION=11.1.0.106 TRTOSS_VERSION= NSIGHT_SYSTEMS_VERSION=2026.3.1.117 NSIGHT_COMPUTE_VERSION=2026.2.1.5 CUSPARSELT_VERSION=0.9.1.1 DALI_VERSION=2.2.0 DALI_BUILD= DALI_URL_SUFFIX=130 POLYGRAPHY_VERSION=0.50.3 TRANSFORMER_ENGINE_VERSION=2.17 MODEL_OPT_VERSION=0.44.0 CUDA_ARCH_LIST=7.5 8.0 8.6 9.0 10.0 12.0 MAXSMVER= NVRX_VERSION=0.6.0 NIXL_VERSION=1.3.0 CUTILE_PYTHON_VERSION=1.4.0 CUTLASS_DSL_VERSION=4.5.2 _LIBPATH_SUFFIX= /bin/bash -c set -euo pipefail cp -r /mnt/aws-efa-installer /tmp/aws-efa-installer cd /tmp/aws-efa-installer ./efa_installer.sh --skip-rdma-core --build-ngc --skip-mpi dpkg -i DEBS/UBUNTU*/$(uname -m)/libfabric-aws-dev_*.deb dpkg -i DEBS/UBUNTU*/$(uname -m)/libfabric-aws-bin_*.deb rm -f /opt/amazon/efa/lib/libfabric.a rm -rf /tmp/aws-efa-installer ldconfig # buildkit

RUN |50 ENABLE_MITMPROXY=0 GDRCOPY_VERSION=2.5.1 HPCX_VERSION=2.50 RDMACORE_VERSION=63.0 MOFED_VERSION=5.4-rdmacore63.0 OPENUCX_VERSION=1.21.0 OPENMPI_VERSION=5.0.10 EFA_VERSION=1.48.0 TARGETARCH=amd64 CUDA_VERSION=13.3.1.008 CUDA_DRIVER_VERSION=610.43.02 NVVM_VERSION=13.3.73 DOCA_VERSION=3.4.0 NCCL_VERSION=2.30.7 CCCL_VERSION=13.3.3.4.1 CUBLAS_VERSION=13.6.0.2 CUFFT_VERSION=12.3.0.29 CURAND_VERSION=10.4.3.29 CUSPARSE_VERSION=12.8.2.51 CUSOLVER_VERSION=12.2.6.9 NPP_VERSION=13.1.2.81 NVJPEG_VERSION=13.2.1.68 CUFILE_VERSION=1.18.1.6 NVJITLINK_VERSION=13.3.33 NVFATBIN_VERSION=13.3.29 CUBLASMP_VERSION=0.9.1.3056 CUSOLVERMP_VERSION=0.8.0.3126 NVSHMEM_VERSION=3.7.1 CUDLA_VERSION=13.3.29 NVPTXCOMPILER_VERSION=13.3.73 CUDNN_VERSION=9.24.0.43 CUDNN_FRONTEND_VERSION=1.25.0 TRT_VERSION=11.1.0.106 TRTOSS_VERSION= NSIGHT_SYSTEMS_VERSION=2026.3.1.117 NSIGHT_COMPUTE_VERSION=2026.2.1.5 CUSPARSELT_VERSION=0.9.1.1 DALI_VERSION=2.2.0 DALI_BUILD= DALI_URL_SUFFIX=130 POLYGRAPHY_VERSION=0.50.3 TRANSFORMER_ENGINE_VERSION=2.17 MODEL_OPT_VERSION=0.44.0 CUDA_ARCH_LIST=7.5 8.0 8.6 9.0 10.0 12.0 MAXSMVER= NVRX_VERSION=0.6.0 NIXL_VERSION=1.3.0 CUTILE_PYTHON_VERSION=1.4.0 CUTLASS_DSL_VERSION=4.5.2 _LIBPATH_SUFFIX= /bin/bash -c set -euo pipefail shopt -s nullglob debs=(/nvidia-networking/opt/gcp/nccl-plugins-ngc-debs/*.deb) if [ "${#debs[@]}" -eq 0 ]; then echo "No GCP NCCL plugin NGC deb staged in networking image; skipping install." exit 0 fi if [ "${#debs[@]}" -ne 1 ]; then echo "Expected exactly one GCP NCCL plugin deb, found ${#debs[@]}:" >&2 printf ' %s\n' "${debs[@]}" >&2 exit 1 fi export DEBIAN_FRONTEND=noninteractive apt-get update apt-get install -y --no-install-recommends "${debs[0]}" rm -rf /var/lib/apt/lists/* if [ -d /opt/gcp/nccl-plugins/lib64 ]; then echo "/opt/gcp/nccl-plugins/lib64" > /etc/ld.so.conf.d/gcp-nccl-plugins.conf ldconfig fi # buildkit

COPY entrypoint/ /opt/nvidia/ # buildkit

ENV NVIDIA_PRODUCT_NAME=CUDA

ENTRYPOINT ["/opt/nvidia/nvidia_entrypoint.sh"]

RUN |50 ENABLE_MITMPROXY=0 GDRCOPY_VERSION=2.5.1 HPCX_VERSION=2.50 RDMACORE_VERSION=63.0 MOFED_VERSION=5.4-rdmacore63.0 OPENUCX_VERSION=1.21.0 OPENMPI_VERSION=5.0.10 EFA_VERSION=1.48.0 TARGETARCH=amd64 CUDA_VERSION=13.3.1.008 CUDA_DRIVER_VERSION=610.43.02 NVVM_VERSION=13.3.73 DOCA_VERSION=3.4.0 NCCL_VERSION=2.30.7 CCCL_VERSION=13.3.3.4.1 CUBLAS_VERSION=13.6.0.2 CUFFT_VERSION=12.3.0.29 CURAND_VERSION=10.4.3.29 CUSPARSE_VERSION=12.8.2.51 CUSOLVER_VERSION=12.2.6.9 NPP_VERSION=13.1.2.81 NVJPEG_VERSION=13.2.1.68 CUFILE_VERSION=1.18.1.6 NVJITLINK_VERSION=13.3.33 NVFATBIN_VERSION=13.3.29 CUBLASMP_VERSION=0.9.1.3056 CUSOLVERMP_VERSION=0.8.0.3126 NVSHMEM_VERSION=3.7.1 CUDLA_VERSION=13.3.29 NVPTXCOMPILER_VERSION=13.3.73 CUDNN_VERSION=9.24.0.43 CUDNN_FRONTEND_VERSION=1.25.0 TRT_VERSION=11.1.0.106 TRTOSS_VERSION= NSIGHT_SYSTEMS_VERSION=2026.3.1.117 NSIGHT_COMPUTE_VERSION=2026.2.1.5 CUSPARSELT_VERSION=0.9.1.1 DALI_VERSION=2.2.0 DALI_BUILD= DALI_URL_SUFFIX=130 POLYGRAPHY_VERSION=0.50.3 TRANSFORMER_ENGINE_VERSION=2.17 MODEL_OPT_VERSION=0.44.0 CUDA_ARCH_LIST=7.5 8.0 8.6 9.0 10.0 12.0 MAXSMVER= NVRX_VERSION=0.6.0 NIXL_VERSION=1.3.0 CUTILE_PYTHON_VERSION=1.4.0 CUTLASS_DSL_VERSION=4.5.2 _LIBPATH_SUFFIX= /bin/bash -c mkdir -p /workspace && cp -f -p /opt/nvidia/entrypoint.d/30-container-license.txt /workspace/license.txt # buildkit

RUN |50 ENABLE_MITMPROXY=0 GDRCOPY_VERSION=2.5.1 HPCX_VERSION=2.50 RDMACORE_VERSION=63.0 MOFED_VERSION=5.4-rdmacore63.0 OPENUCX_VERSION=1.21.0 OPENMPI_VERSION=5.0.10 EFA_VERSION=1.48.0 TARGETARCH=amd64 CUDA_VERSION=13.3.1.008 CUDA_DRIVER_VERSION=610.43.02 NVVM_VERSION=13.3.73 DOCA_VERSION=3.4.0 NCCL_VERSION=2.30.7 CCCL_VERSION=13.3.3.4.1 CUBLAS_VERSION=13.6.0.2 CUFFT_VERSION=12.3.0.29 CURAND_VERSION=10.4.3.29 CUSPARSE_VERSION=12.8.2.51 CUSOLVER_VERSION=12.2.6.9 NPP_VERSION=13.1.2.81 NVJPEG_VERSION=13.2.1.68 CUFILE_VERSION=1.18.1.6 NVJITLINK_VERSION=13.3.33 NVFATBIN_VERSION=13.3.29 CUBLASMP_VERSION=0.9.1.3056 CUSOLVERMP_VERSION=0.8.0.3126 NVSHMEM_VERSION=3.7.1 CUDLA_VERSION=13.3.29 NVPTXCOMPILER_VERSION=13.3.73 CUDNN_VERSION=9.24.0.43 CUDNN_FRONTEND_VERSION=1.25.0 TRT_VERSION=11.1.0.106 TRTOSS_VERSION= NSIGHT_SYSTEMS_VERSION=2026.3.1.117 NSIGHT_COMPUTE_VERSION=2026.2.1.5 CUSPARSELT_VERSION=0.9.1.1 DALI_VERSION=2.2.0 DALI_BUILD= DALI_URL_SUFFIX=130 POLYGRAPHY_VERSION=0.50.3 TRANSFORMER_ENGINE_VERSION=2.17 MODEL_OPT_VERSION=0.44.0 CUDA_ARCH_LIST=7.5 8.0 8.6 9.0 10.0 12.0 MAXSMVER= NVRX_VERSION=0.6.0 NIXL_VERSION=1.3.0 CUTILE_PYTHON_VERSION=1.4.0 CUTLASS_DSL_VERSION=4.5.2 _LIBPATH_SUFFIX= /bin/bash -c /tmp/manage_cert.sh uninstall # buildkit

ARG ENABLE_MITMPROXY=0
ARG ENABLE_FIPS=0

RUN |2 ENABLE_MITMPROXY=0 ENABLE_FIPS=0 /bin/bash -c /tmp/manage_cert.sh install # buildkit

RUN |2 ENABLE_MITMPROXY=0 ENABLE_FIPS=0 /bin/bash -c export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y --no-install-recommends apt-utils build-essential libncurses6 libncursesw6 unzip jq gnupg libtcmalloc-minimal4 git libglib2.0-0 libhwloc15 libnuma-dev libnuma1 libpmi2-0-dev numactl openssh-client vim-tiny wget && rm -rf /var/lib/apt/lists/* && if [ "${ENABLE_FIPS}" = "1" ]; then apt-get remove -y openssh-client && cp -f -p /tmp/ubuntu.sources.fips /etc/apt/sources.list.d/ubuntu.sources && apt-get update && apt-get install -y --no-install-recommends openssh-client && rm -rf /var/lib/apt/lists/*; fi && ( [ -x /bin/ssh-agent ] && chgrp root /bin/ssh-agent || true ) && ( [ -x /usr/bin/ssh-agent ] && chgrp root /usr/bin/ssh-agent || true ) # buildkit

ARG CUDA_COMPONENT_LIST=crt nvrtc driver-dev culibos-dev cudart cudart-dev nvcc tileiras

ENV CUDA_COMPONENT_LIST=crt nvrtc driver-dev culibos-dev cudart cudart-dev nvcc tileiras

RUN |3 ENABLE_MITMPROXY=0 ENABLE_FIPS=0 CUDA_COMPONENT_LIST=crt nvrtc driver-dev culibos-dev cudart cudart-dev nvcc tileiras /bin/bash -c set -exo pipefail export ARTIFACTORY_USER=$(cat /run/secrets/ARTIFACTORY_USER) export ARTIFACTORY_TOKEN=$(cat /run/secrets/ARTIFACTORY_TOKEN) # We need CCCL first since cuda-cudart-dev depends on it DEVEL=0 BASE=1 VERSION_LIST="CCCL_VERSION" /nvidia/build-scripts/installLIBS.sh COMPONENT_LIST="${CUDA_COMPONENT_LIST}" /nvidia/build-scripts/installCUDA.sh # buildkit

ARG VERSION_LIST=CURAND_VERSION CUBLAS_VERSION CUFILE_VERSION

RUN |4 ENABLE_MITMPROXY=0 ENABLE_FIPS=0 CUDA_COMPONENT_LIST=crt nvrtc driver-dev culibos-dev cudart cudart-dev nvcc tileiras VERSION_LIST=CURAND_VERSION CUBLAS_VERSION CUFILE_VERSION /bin/bash -c set -exo pipefail export ARTIFACTORY_USER=$(cat /run/secrets/ARTIFACTORY_USER) export ARTIFACTORY_TOKEN=$(cat /run/secrets/ARTIFACTORY_TOKEN) VERSION_LIST="${VERSION_LIST}" /nvidia/build-scripts/installLIBS.sh # Hack to grab stubs from the libs stage and put them under /usr/local/cuda/lib64 without actually installing the libs HACK_LIST="cusparse cusolver cufft nvJitLink" for lib in ${HACK_LIST}; do _LIB_VERSION_ENV_VAR="${lib^^}_VERSION" _LIB_MAJOR_VERSION=$(echo "${!_LIB_VERSION_ENV_VAR}" | cut -d. -f1) if [[ -z "${_LIB_MAJOR_VERSION}" ]]; then echo "[ERROR] ${_LIB_VERSION_ENV_VAR} is not set" exit 1 fi for _stub in $(ls /tmp/stubs/*${lib}*); do cp ${_stub} /usr/local/cuda/lib64/$(basename ${_stub}).${_LIB_MAJOR_VERSION} # Create a symlink to the file with .0 extension ln -sf $(basename ${_stub}).${_LIB_MAJOR_VERSION} /usr/local/cuda/lib64/$(basename ${_stub}).0 done done ( set +x; echo "[INFO] /usr/local/cuda/lib64 after hack:"; ls -larth /usr/local/cuda/lib64/ ) /nvidia/build-scripts/installCUDNN.sh /nvidia/build-scripts/installCUSPARSELT.sh NOBUILDER=1 /nvidia/build-scripts/installTRT.sh /nvidia/build-scripts/installNCCL.sh DPKG_DIVERT=1 /nvidia/build-scripts/installNVSHMEM.sh ls /usr/local/cuda/lib64/libnvshmem_host.so* || { echo "[ERROR] libnvshmem_host.so* not found under /usr/local/cuda/lib64"; exit 1; } # buildkit

ENV LIBRARY_PATH=/usr/local/cuda/lib64/stubs:

RUN |4 ENABLE_MITMPROXY=0 ENABLE_FIPS=0 CUDA_COMPONENT_LIST=crt nvrtc driver-dev culibos-dev cudart cudart-dev nvcc tileiras VERSION_LIST=CURAND_VERSION CUBLAS_VERSION CUFILE_VERSION /bin/bash -c /tmp/manage_cert.sh uninstall # buildkit

LABEL com.nvidia.nccl.version=2.30.7 com.nvidia.cublas.version=13.6.0.2 com.nvidia.cufft.version=12.3.0.29 com.nvidia.curand.version=10.4.3.29 com.nvidia.cusparse.version=12.8.2.51 com.nvidia.cusparselt.version=0.9.1.1 com.nvidia.cusolver.version=12.2.6.9 com.nvidia.npp.version=13.1.2.81 com.nvidia.nvjpeg.version=13.2.1.68 com.nvidia.cudnn.version=9.24.0.43

ARG ENABLE_MITMPROXY=0

RUN |1 ENABLE_MITMPROXY=0 /bin/bash -c /tmp/manage_cert.sh install # buildkit

RUN |1 ENABLE_MITMPROXY=0 /bin/bash -c export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y --no-install-recommends build-essential libncurses6 libncursesw6 unzip jq gnupg libtcmalloc-minimal4 && rm -rf /var/lib/apt/lists/* # buildkit

RUN |1 ENABLE_MITMPROXY=0 /bin/bash -c export ARTIFACTORY_USER=$(cat /run/secrets/ARTIFACTORY_USER) && export ARTIFACTORY_TOKEN=$(cat /run/secrets/ARTIFACTORY_TOKEN) && /nvidia/build-scripts/installCUDA.sh # buildkit

RUN |1 ENABLE_MITMPROXY=0 /bin/bash -c export ARTIFACTORY_USER=$(cat /run/secrets/ARTIFACTORY_USER) && export ARTIFACTORY_TOKEN=$(cat /run/secrets/ARTIFACTORY_TOKEN) && PURGESTUBS="1" /nvidia/build-scripts/installLIBS.sh && /nvidia/build-scripts/installCUDNN.sh && /nvidia/build-scripts/installTRT.sh && ARTIFACTORY_CLOUD=1 /nvidia/build-scripts/installNSYS.sh && /nvidia/build-scripts/installNCU.sh && /nvidia/build-scripts/installCUSPARSELT.sh && /nvidia/build-scripts/installNCCL.sh # buildkit

LABEL com.nvidia.nccl.version=2.30.7 com.nvidia.cublas.version=13.6.0.2 com.nvidia.cufft.version=12.3.0.29 com.nvidia.curand.version=10.4.3.29 com.nvidia.cusparse.version=12.8.2.51 com.nvidia.cusparselt.version=0.9.1.1 com.nvidia.cusolver.version=12.2.6.9 com.nvidia.npp.version=13.1.2.81 com.nvidia.nvjpeg.version=13.2.1.68 com.nvidia.cublasmp.version=0.9.1.3056 com.nvidia.cusolvermp.version=0.8.0.3126 com.nvidia.nvvm.version=13.3.73 com.nvidia.cudla.version=13.3.29 com.nvidia.cudnn.version=9.24.0.43 com.nvidia.tensorrt.version=11.1.0.106 com.nvidia.tensorrtoss.version= com.nvidia.nsightsystems.version=2026.3.1.117 com.nvidia.nsightcompute.version=2026.2.1.5

RUN |1 ENABLE_MITMPROXY=0 /bin/bash -c /tmp/manage_cert.sh uninstall # buildkit

ARG TARGETARCH=amd64
ARG ENABLE_FIPS=0
ARG ENABLE_MITMPROXY=0

RUN |3 TARGETARCH=amd64 ENABLE_FIPS=0 ENABLE_MITMPROXY=0 /bin/bash -c /tmp/manage_cert.sh install # buildkit

RUN |3 TARGETARCH=amd64 ENABLE_FIPS=0 ENABLE_MITMPROXY=0 /bin/bash -c export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y --no-install-recommends build-essential git libglib2.0-0 less libhwloc15 libnuma-dev libnuma1 libpmi2-0-dev nano numactl openssh-client vim wget && rm -rf /var/lib/apt/lists/* && if [ "${ENABLE_FIPS}" = "1" ]; then apt-get remove -y openssh-client && cp -f -p /tmp/ubuntu.sources.fips /etc/apt/sources.list.d/ubuntu.sources && apt-get update && apt-get install -y --no-install-recommends openssh-client && rm -rf /var/lib/apt/lists/*; fi && ( [ -x /bin/ssh-agent ] && chgrp root /bin/ssh-agent || true ) && ( [ -x /usr/bin/ssh-agent ] && chgrp root /usr/bin/ssh-agent || true ) # buildkit

COPY cuda-*.patch /tmp # buildkit

RUN |3 TARGETARCH=amd64 ENABLE_FIPS=0 ENABLE_MITMPROXY=0 /bin/bash -c set -exo pipefail export ARTIFACTORY_USER=$(cat /run/secrets/ARTIFACTORY_USER) export ARTIFACTORY_TOKEN=$(cat /run/secrets/ARTIFACTORY_TOKEN) export DEVEL=1 BASE=0 /nvidia/build-scripts/installNCU.sh /nvidia/build-scripts/installCUDA.sh /nvidia/build-scripts/installLIBS.sh /nvidia/build-scripts/installNCCL.sh # https://jirasw.nvidia.com/browse/DLR-4957 to get the headers and static files with symlinks to the common location DPKG_DIVERT=1 STATIC=1 /nvidia/build-scripts/installNVSHMEM.sh /nvidia/build-scripts/installCUDNN.sh /nvidia/build-scripts/installTRT.sh ARTIFACTORY_CLOUD=1 /nvidia/build-scripts/installNSYS.sh /nvidia/build-scripts/installCUSPARSELT.sh if [ -f "/tmp/cuda-${_CUDA_VERSION_MAJMIN}.patch" ]; then patch -p0 < /tmp/cuda-${_CUDA_VERSION_MAJMIN}.patch; fi rm -f /tmp/cuda-*.patch # buildkit

ENV LIBRARY_PATH=/usr/local/cuda/lib64/stubs:/usr/local/cuda/lib64/stubs:

RUN |3 TARGETARCH=amd64 ENABLE_FIPS=0 ENABLE_MITMPROXY=0 /bin/bash -c /tmp/manage_cert.sh uninstall # buildkit

ENV NVIDIA_PRODUCT_NAME=PyTorch

ARG NVIDIA_PYTORCH_VERSION=26.07
ARG PYTORCH_BUILD_VERSION=2.13.0a0+9186a08
ARG NVFUSER_BUILD_VERSION=

ENV PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 PYTORCH_VERSION=2.13.0a0+9186a08 PYTORCH_BUILD_NUMBER=0 NVIDIA_PYTORCH_VERSION=26.07
ENV NVFUSER_BUILD_VERSION=0.1.4a0+nvidia NVFUSER_VERSION=

ARG TORCHAO_BUILD_VERSION=+git18278f9b

ENV TORCHAO_BUILD_VERSION=+git18278f9b

ARG TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe

ENV TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe

LABEL com.nvidia.pytorch.version=2.13.0a0+9186a08

ARG TARGETARCH=amd64
ARG PYVER=3.12

ENV PIP_BREAK_SYSTEM_PACKAGES=1

ARG ENABLE_MITMPROXY=0

RUN |8 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 /bin/bash -c /tmp/manage_cert.sh install # buildkit

RUN |8 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 /bin/bash -c export PYSFX=`echo "${PYVER}" | cut -c1-1` && export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y --no-install-recommends python$PYVER-dev python$PYSFX python$PYSFX-dev python$PYSFX-pip python$PYSFX-venv python-is-python$PYSFX autoconf automake libatlas-base-dev libgoogle-glog-dev libbz2-dev libc-ares2 libre2-dev libleveldb-dev liblmdb-dev libprotobuf-dev libsnappy-dev libtool nasm protobuf-compiler pkg-config unzip sox libsndfile1 libpng-dev rapidjson-dev ninja-build libedit-dev build-essential patchelf llvm-dev libzstd-dev && rm -rf /var/lib/apt/lists/* # buildkit

ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
ENV PIP_CONSTRAINT=/etc/pip/constraint.txt

COPY constraint.txt /etc/pip/constraint.txt # buildkit

RUN |8 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 /bin/bash -c pip install --ignore-installed --upgrade pip setuptools wheel && pip install cmake # buildkit

RUN |8 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 /bin/bash -c if [ $TARGETARCH = "arm64" ]; then cd /opt && curl -Of "https://developer.download.nvidia.com/compute/nvpl/redist/nvpl_blas/linux-sbsa/nvpl_blas-linux-sbsa-0.5.0.1-archive.tar.xz" && curl -Of "https://developer.download.nvidia.com/compute/nvpl/redist/nvpl_lapack/linux-sbsa/nvpl_lapack-linux-sbsa-0.3.2-archive.tar.xz" && tar xf nvpl_blas-linux-sbsa-0.5.0.1-archive.tar.xz && tar xf nvpl_lapack-linux-sbsa-0.3.2-archive.tar.xz && cp -r nvpl_blas-linux-sbsa-0.5.0.1-archive/lib/* /usr/local/lib && cp -r nvpl_blas-linux-sbsa-0.5.0.1-archive/include/* /usr/local/include && cp -r nvpl_lapack-linux-sbsa-0.3.2-archive/lib/* /usr/local/lib && cp -r nvpl_lapack-linux-sbsa-0.3.2-archive/include/* /usr/local/include && rm -rf ./nvpl_* ; fi # buildkit

ENV NVPL_LAPACK_MATH_MODE=PEDANTIC

WORKDIR /opt/pytorch

ENV PYTHONIOENCODING=utf-8

ENV LC_ALL=C.UTF-8

ENV PIP_DEFAULT_TIMEOUT=100

RUN |8 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 /bin/bash -c pip install scipy numba==0.64.0 pybind11 Cython regex protobuf nvidia-cutlass-dsl[cu13]==${CUTLASS_DSL_VERSION} apache-tvm-ffi cuda-tile==${CUTILE_PYTHON_VERSION} && if [[ $TARGETARCH = "amd64" ]] ; then pip install --no-cache-dir mkl mkl-include mkl-devel ; find /usr/local/lib -maxdepth 1 -type f -regex '.*\/lib\(tbb\|mkl\).*\.so\($\|\.[0-9]*\.[0-9]*\)' -exec rm -v {} + ; fi # buildkit

COPY . . # buildkit

RUN |8 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 /bin/bash -c git config --global url."https://github".insteadOf git://github && pip install jupyterlab notebook tensorboard jupyterlab_code_formatter python-hostlist && PATCHED_FILE=$(python -c "from tensorboard.plugins.core import core_plugin as _; print(_.__file__)") && sed -i 's/^\( *"--bind_all",\)$/\1 default=True,/' "$PATCHED_FILE" && test $(grep '^ *"--bind_all", default=True,$' "$PATCHED_FILE" | wc -l) -eq 1 # buildkit

WORKDIR /opt/pytorch

RUN |8 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 /bin/bash -c pip install --no-cache-dir /builder/*.whl jupytext black isort && mkdir -p /usr/local/etc/jupyter /root/.jupyter/lab/user-settings/@jupyterlab/completer-extension/ && cp /tmp/jupyter_config/jupyter_notebook_config.py /usr/local/etc/jupyter/ && cp /tmp/jupyter_config/manager.jupyterlab-settings /root/.jupyter/lab/user-settings/@jupyterlab/completer-extension/ && cp /tmp/jupyter_config/settings.jupyterlab-settings /root/.jupyter/lab/user-settings/@jupyterlab/completer-extension/ && jupyter lab clean # buildkit

ENV JUPYTER_PORT=8888

ENV TENSORBOARD_PORT=6006

EXPOSE [8888/tcp]
EXPOSE [6006/tcp]

ENV UCC_CL_BASIC_TLS=^sharp
ENV UCC_EC_CUDA_EXEC_NUM_THREADS=256
ENV TORCH_CUDA_ARCH_LIST=7.5 8.0 8.6 9.0 10.0 12.0+PTX
ENV PYTORCH_HOME=/opt/pytorch/pytorch
ENV CUDA_HOME=/usr/local/cuda
ENV TORCH_ALLOW_TF32_CUBLAS_OVERRIDE=1
ENV TORCHINDUCTOR_CUTLASS_DIR=/opt/pytorch/pytorch/third_party/cutlass

RUN |8 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 /bin/bash -c echo "TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}" && pip install /opt/transfer/torch*.whl && patchelf --set-rpath '/usr/local/lib' /usr/local/lib/python${PYVER}/dist-packages/torch/lib/libtorch_global_deps.so # buildkit

RUN |8 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 /bin/bash -c mkdir -p /usr/local/share/cmake/TorchVision /usr/local/include/torchvision && cp -a /tmp/TorchVision/. /usr/local/share/cmake/TorchVision/ && cp -a /tmp/torchvision-include/. /usr/local/include/torchvision/ && cp -a /tmp/libtorchvision.so.1.0 /usr/local/lib/libtorchvision.so.1.0 && patchelf --set-soname libjpeg.so.62 --output /usr/local/lib/libjpeg.so.62 $(readlink -f $(ldd /usr/local/lib/python${PYVER}/dist-packages/torchvision/image.so | grep libjpeg | awk '{print $3}')) # buildkit

RUN |8 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 /bin/bash -c pip install --no-cache-dir --no-deps /tmp/dist/*.whl # buildkit

ENV TRITON_PTXAS_PATH=/usr/local/cuda/bin/ptxas
ENV TRITON_CUOBJDUMP_PATH=/usr/local/cuda/bin/cuobjdump
ENV TRITON_NVDISASM_PATH=/usr/local/cuda/bin/nvdisasm
ENV TRITON_CUDACRT_PATH=/usr/local/cuda/include
ENV TRITON_CUDART_PATH=/usr/local/cuda/include
ENV TRITON_CUPTI_LIB_PATH=/usr/local/cuda/lib64
ENV TRITON_CUPTI_INCLUDE_PATH=/usr/local/cuda/include

ARG DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali

RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c export CUDA_VERSION_MAJOR=$(ls /usr/local/cuda/lib64/libcudart.so.*.*.* | cut -d . -f 3) && export DALI_PKG_SUFFIX="cuda${CUDA_VERSION_MAJOR}0" && if [ -z "${DALI_URL_SUFFIX}" ] ; then export DALI_EXTRA_INDEX_URL="${DALI_EXTRA_INDEX_URL}-qa/nvidia-dali-cudagpgpu"; fi && pip install --extra-index-url https://developer.download.nvidia.com/compute/redist --extra-index-url "${DALI_EXTRA_INDEX_URL}" --extra-index-url "http://sqrl/nvdl/datasets/dali/misc" --trusted-host sqrl nvidia-dali-${DALI_PKG_SUFFIX}==${DALI_VERSION} # buildkit

ENV COCOAPI_VERSION=2.0+nv0.8.1
RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c export COCOAPI_TAG=$(echo ${COCOAPI_VERSION} | sed 's/^.*+n//') && pip install --no-build-isolation git+https://github.com/nvidia/cocoapi.git@${COCOAPI_TAG}#subdirectory=PythonAPI # buildkit

COPY singularity/ /.singularity.d/ # buildkit

RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c /tmp/manage_cert.sh install # buildkit

RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c export ARTIFACTORY_USER=$(cat /run/secrets/ARTIFACTORY_USER) && export ARTIFACTORY_TOKEN=$(cat /run/secrets/ARTIFACTORY_TOKEN) && /nvidia/build-scripts/installCUBLASMP.sh && ( cd pytorch/third_party/onnx && pip uninstall typing -y && CMAKE_ARGS="-DONNX_USE_PROTOBUF_SHARED_LIBS=ON" pip install --no-build-isolation . ) && ( cd ao && TORCH_CUDA_ARCH_LIST="9.0a 10.0a ${TORCH_CUDA_ARCH_LIST}" VERSION_SUFFIX="${TORCHAO_BUILD_VERSION}" pip install --no-build-isolation . && python setup.py clean --all ) && ( cd torchtitan && BUILD_VERSION="${TORCHTITAN_BUILD_VERSION}" bash .github/scripts/update_version.sh && pip install --no-build-isolation . && rm -rf build/ ) # buildkit

RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c pip install tabulate # buildkit

WORKDIR /workspace

COPY NVREADME.md README.md # buildkit
COPY docker-examples docker-examples # buildkit
COPY tutorials tutorials # buildkit

RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c chmod -R a+w+t . # buildkit

RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c set -xeo pipefail apt-get update apt-get install -y --no-install-recommends zstd export ARTIFACTORY_USER=$(cat /run/secrets/ARTIFACTORY_USER) export ARTIFACTORY_TOKEN=$(cat /run/secrets/ARTIFACTORY_TOKEN) WHEELS=1 /nvidia/build-scripts/installTRT.sh # Remove zstd after installTRT.sh apt-get purge -y --auto-remove zstd apt-get clean rm -rf /var/lib/apt/lists/* # buildkit

ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/mpi/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/ucx/bin:/opt/amazon/efa/bin:/opt/tensorrt/bin

RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c pip --version && python -c 'import sys; print(sys.platform)' && pip install --extra-index-url https://urm.nvidia.com/artifactory/api/pypi/sw-tensorrt-pypi/simple --no-cache-dir "polygraphy==${POLYGRAPHY_VERSION}" && pip download --no-deps -d /tmp/modelopt --index-url https://gitlab-master.nvidia.com/api/v4/projects/omniml%2Fmodelopt/packages/pypi/simple --extra-index-url https://pypi.nvidia.com "nvidia-modelopt[torch]==${MODEL_OPT_VERSION}" && pip install /tmp/modelopt/nvidia_modelopt*.whl && rm -rf /tmp/modelopt && pip download --no-deps -d /tmp/nvrx --index-url https://gitlab-master.nvidia.com/api/v4/projects/dl%2Fosiris%2Fnvidia-resiliency-ext-ci/packages/pypi/simple nvidia-resiliency-ext==${NVRX_VERSION} && pip install /tmp/nvrx/nvidia_resiliency_ext*.whl && rm -rf /tmp/nvrx && pip uninstall -y pynvml # buildkit

COPY torch_tensorrt/ /opt/pytorch/torch_tensorrt/ # buildkit

ARG PYVER=3.12

ENV LD_LIBRARY_PATH=/usr/local/lib/python3.12/dist-packages/torch/lib:/usr/local/lib/python3.12/dist-packages/torch_tensorrt/lib:/usr/local/cuda/compat/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV PATH=/usr/local/lib/python3.12/dist-packages/torch_tensorrt/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/mpi/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/ucx/bin:/opt/amazon/efa/bin:/opt/tensorrt/bin

RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c pip install --no-cache-dir /opt/pytorch/apex/dist/*.whl && pip install --no-cache-dir /opt/pytorch/torch_tensorrt/dist/*.whl && pip install --no-cache-dir /opt/transfer/flash_attn*.whl # buildkit

RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c ARTIFACTORY_USER=$(cat /run/secrets/ARTIFACTORY_USER) ARTIFACTORY_TOKEN=$(cat /run/secrets/ARTIFACTORY_TOKEN) /nvidia/build-scripts/installCUSOLVERMP.sh # buildkit

RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c git clone -b release_v${TRANSFORMER_ENGINE_VERSION} --single-branch --recursive https://github.com/NVIDIA/TransformerEngine.git && _NVTE_CUDA_ARCHS=$(echo "${CUDA_ARCH_LIST}" | tr -d '.') && NVTE_CUDA_ARCHS=$(echo "${_NVTE_CUDA_ARCHS}" | tr ' ' ';') && env NVTE_CUDA_ARCHS="${NVTE_CUDA_ARCHS};89;100a;103a" NVTE_BUILD_THREADS_PER_JOB=8 pip install --no-cache-dir --no-build-isolation ./TransformerEngine && rm -rf TransformerEngine # buildkit

RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c /tmp/manage_cert.sh uninstall # buildkit

ENV CUDA_BINARY_LOADER_THREAD_COUNT=8
ENV CUDA_MODULE_LOADING=LAZY
ENV TORCH_NCCL_USE_COMM_NONBLOCKING=0
ENV TORCHINDUCTOR_LOOP_ORDERING_AFTER_FUSION=0

RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c ln -sf ${_CUDA_COMPAT_PATH}/lib.real ${_CUDA_COMPAT_PATH}/lib && echo ${_CUDA_COMPAT_PATH}/lib > /etc/ld.so.conf.d/00-cuda-compat.conf && ldconfig && rm -f ${_CUDA_COMPAT_PATH}/lib # buildkit

RUN |9 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali /bin/bash -c cp /tmp/restricted_constraint.txt /etc/pip/constraint.txt && cp /tmp/original_constraint.txt /etc/pip/original_constraint.txt # buildkit

COPY entrypoint.d/ /opt/nvidia/entrypoint.d/ # buildkit

ARG ENABLE_FIPS=0

RUN |10 NVIDIA_PYTORCH_VERSION=26.07 PYTORCH_BUILD_VERSION=2.13.0a0+9186a08 NVFUSER_BUILD_VERSION=0.1.4a0+nvidia TORCHAO_BUILD_VERSION=+git18278f9b TORCHTITAN_BUILD_VERSION=0.2.2+gitebfceebe TARGETARCH=amd64 PYVER=3.12 ENABLE_MITMPROXY=0 DALI_EXTRA_INDEX_URL=http://sqrl/nvdl/datasets/dali/pip-dali ENABLE_FIPS=0 /bin/bash -c if [ "${ENABLE_FIPS}" = "1" ] && [ "${TARGETARCH}" = "amd64" ]; then echo "Running fips-fix.sh"; /tmp/fips-fix.sh; fi # buildkit

ARG NVIDIA_BUILD_ID=373437298

ENV NVIDIA_BUILD_ID=373437298

LABEL com.nvidia.build.id=373437298

ARG NVIDIA_BUILD_REF=f0144140a7c872635fafcadbd58fcbd63265d789

LABEL com.nvidia.build.ref=f0144140a7c872635fafcadbd58fcbd63265d789

ARG TARGETPLATFORM=linux/amd64

COPY /uv /uvx /bin/ # buildkit

ENV UV_SYSTEM_PYTHON=1 UV_BREAK_SYSTEM_PACKAGES=1 UV_LINK_MODE=copy _CUDA_COMPAT_TIMEOUT=90

RUN |1 TARGETPLATFORM=linux/amd64 /bin/bash -c uv pip install "pip>=23.2.1" "setuptools>=77.0.3" && apt-get update && apt-get install -y git-lfs graphviz libgl1 zip unzip && git lfs install && FILE="/etc/pip/constraint.txt" && if [ -f "$FILE" ]; then sed -i '/packaging/d' "$FILE"; else echo "File not found: $FILE"; fi && { [ -f /etc/pip/constraint.txt ] || touch /etc/pip/constraint.txt; } && rm -rf /var/lib/apt/lists/* # buildkit

ENV UV_CONSTRAINT=/etc/pip/constraint.txt

ARG PYSPNG_ARM64_WHEEL=pyspng-0.1.2-cp312-cp312-linux_aarch64.whl
ARG NUMCODECS_ARM64_WHEEL
ARG ONNXRUNTIME_ARM64_WHEEL=onnxruntime_gpu-1.20.2-cp312-cp312-linux_aarch64.whl
ARG TORCH_SCATTER_ARM64_WHEEL=torch_scatter-2.1.2-cp312-cp312-linux_aarch64.whl
ARG TORCH_SCATTER_AMD64_WHEEL=torch_scatter-2.1.2-cp312-cp312-linux_x86_64.whl
ARG PYGLIB_ARM64_WHEEL
ARG PYGLIB_AMD64_WHEEL
ARG TORCH_CLUSTER_ARM64_WHEEL=torch_cluster-1.6.3-cp312-cp312-linux_aarch64.whl
ARG TORCH_CLUSTER_AMD64_WHEEL=torch_cluster-1.6.3-cp312-cp312-linux_x86_64.whl
ARG NATTEN_ARM64_WHEEL=natten-0.21.5-cp312-cp312-linux_aarch64.whl
ARG NATTEN_AMD64_WHEEL=natten-0.21.5-cp312-cp312-linux_x86_64.whl

ENV PYSPNG_ARM64_WHEEL=pyspng-0.1.2-cp312-cp312-linux_aarch64.whl NUMCODECS_ARM64_WHEEL=unknown ONNXRUNTIME_ARM64_WHEEL=onnxruntime_gpu-1.20.2-cp312-cp312-linux_aarch64.whl TORCH_SCATTER_ARM64_WHEEL=torch_scatter-2.1.2-cp312-cp312-linux_aarch64.whl TORCH_SCATTER_AMD64_WHEEL=torch_scatter-2.1.2-cp312-cp312-linux_x86_64.whl PYGLIB_ARM64_WHEEL=unknown PYGLIB_AMD64_WHEEL=unknown TORCH_CLUSTER_ARM64_WHEEL=torch_cluster-1.6.3-cp312-cp312-linux_aarch64.whl TORCH_CLUSTER_AMD64_WHEEL=torch_cluster-1.6.3-cp312-cp312-linux_x86_64.whl NATTEN_ARM64_WHEEL=natten-0.21.5-cp312-cp312-linux_aarch64.whl NATTEN_AMD64_WHEEL=natten-0.21.5-cp312-cp312-linux_x86_64.whl TORCH_CUDA_ARCH_LIST=7.5 8.0 8.6 9.0 10.0 12.0+PTX NATTEN_CUDA_ARCH=8.0;8.6;9.0;10.0;12.0

RUN |12 TARGETPLATFORM=linux/amd64 PYSPNG_ARM64_WHEEL=pyspng-0.1.2-cp312-cp312-linux_aarch64.whl NUMCODECS_ARM64_WHEEL=unknown ONNXRUNTIME_ARM64_WHEEL=onnxruntime_gpu-1.20.2-cp312-cp312-linux_aarch64.whl TORCH_SCATTER_ARM64_WHEEL=torch_scatter-2.1.2-cp312-cp312-linux_aarch64.whl TORCH_SCATTER_AMD64_WHEEL=torch_scatter-2.1.2-cp312-cp312-linux_x86_64.whl PYGLIB_ARM64_WHEEL=unknown PYGLIB_AMD64_WHEEL=unknown TORCH_CLUSTER_ARM64_WHEEL=torch_cluster-1.6.3-cp312-cp312-linux_aarch64.whl TORCH_CLUSTER_AMD64_WHEEL=torch_cluster-1.6.3-cp312-cp312-linux_x86_64.whl NATTEN_ARM64_WHEEL=natten-0.21.5-cp312-cp312-linux_aarch64.whl NATTEN_AMD64_WHEEL=natten-0.21.5-cp312-cp312-linux_x86_64.whl /bin/bash -c bash /tmp/install-container-dependencies.sh # buildkit

RUN |12 TARGETPLATFORM=linux/amd64 PYSPNG_ARM64_WHEEL=pyspng-0.1.2-cp312-cp312-linux_aarch64.whl NUMCODECS_ARM64_WHEEL=unknown ONNXRUNTIME_ARM64_WHEEL=onnxruntime_gpu-1.20.2-cp312-cp312-linux_aarch64.whl TORCH_SCATTER_ARM64_WHEEL=torch_scatter-2.1.2-cp312-cp312-linux_aarch64.whl TORCH_SCATTER_AMD64_WHEEL=torch_scatter-2.1.2-cp312-cp312-linux_x86_64.whl PYGLIB_ARM64_WHEEL=unknown PYGLIB_AMD64_WHEEL=unknown TORCH_CLUSTER_ARM64_WHEEL=torch_cluster-1.6.3-cp312-cp312-linux_aarch64.whl TORCH_CLUSTER_AMD64_WHEEL=torch_cluster-1.6.3-cp312-cp312-linux_x86_64.whl NATTEN_ARM64_WHEEL=natten-0.21.5-cp312-cp312-linux_aarch64.whl NATTEN_AMD64_WHEEL=natten-0.21.5-cp312-cp312-linux_x86_64.whl /bin/bash -c cd /tmp && uv pip install --no-cache --no-binary torch-sparse --no-build-isolation "torch-sparse>=0.6.18" && uv pip install -r pyproject.toml --extra cu13 --extra utils-extras --extra mesh-extras --extra datapipes-extras --extra gnns --extra sym && python -c 'import torch, torch_cluster, torch_scatter, torch_sparse; import natten.libnatten; print("Native extension ABI check passed:", torch.__version__)' # buildkit

RUN |12 TARGETPLATFORM=linux/amd64 PYSPNG_ARM64_WHEEL=pyspng-0.1.2-cp312-cp312-linux_aarch64.whl NUMCODECS_ARM64_WHEEL=unknown ONNXRUNTIME_ARM64_WHEEL=onnxruntime_gpu-1.20.2-cp312-cp312-linux_aarch64.whl TORCH_SCATTER_ARM64_WHEEL=torch_scatter-2.1.2-cp312-cp312-linux_aarch64.whl TORCH_SCATTER_AMD64_WHEEL=torch_scatter-2.1.2-cp312-cp312-linux_x86_64.whl PYGLIB_ARM64_WHEEL=unknown PYGLIB_AMD64_WHEEL=unknown TORCH_CLUSTER_ARM64_WHEEL=torch_cluster-1.6.3-cp312-cp312-linux_aarch64.whl TORCH_CLUSTER_AMD64_WHEEL=torch_cluster-1.6.3-cp312-cp312-linux_x86_64.whl NATTEN_ARM64_WHEEL=natten-0.21.5-cp312-cp312-linux_aarch64.whl NATTEN_AMD64_WHEEL=natten-0.21.5-cp312-cp312-linux_x86_64.whl /bin/bash -c cd /physicsnemo && uv pip install --no-deps . # buildkit

RUN |12 TARGETPLATFORM=linux/amd64 PYSPNG_ARM64_WHEEL=pyspng-0.1.2-cp312-cp312-linux_aarch64.whl NUMCODECS_ARM64_WHEEL=unknown ONNXRUNTIME_ARM64_WHEEL=onnxruntime_gpu-1.20.2-cp312-cp312-linux_aarch64.whl TORCH_SCATTER_ARM64_WHEEL=torch_scatter-2.1.2-cp312-cp312-linux_aarch64.whl TORCH_SCATTER_AMD64_WHEEL=torch_scatter-2.1.2-cp312-cp312-linux_x86_64.whl PYGLIB_ARM64_WHEEL=unknown PYGLIB_AMD64_WHEEL=unknown TORCH_CLUSTER_ARM64_WHEEL=torch_cluster-1.6.3-cp312-cp312-linux_aarch64.whl TORCH_CLUSTER_AMD64_WHEEL=torch_cluster-1.6.3-cp312-cp312-linux_x86_64.whl NATTEN_ARM64_WHEEL=natten-0.21.5-cp312-cp312-linux_aarch64.whl NATTEN_AMD64_WHEEL=natten-0.21.5-cp312-cp312-linux_x86_64.whl /bin/bash -c uv pip uninstall mlflow wandb && uv cache clean # buildkit

ARG PHYSICSNEMO_GIT_HASH=a078229

ENV PHYSICSNEMO_GIT_HASH=a078229

RUN /bin/bash -c mkdir -p NVIDIA_PhysicsNeMo_accompanying_licenses /opt/nvidia/entrypoint.d && cp -a /tmp/accompanying_licenses/. NVIDIA_PhysicsNeMo_accompanying_licenses/ && cp -a /tmp/13-physicsnemo-versions.sh /opt/nvidia/entrypoint.d/13-physicsnemo-versions.sh && cp -a /tmp/physicsnemo_env.sh /opt/nvidia/physicsnemo_env.sh && chown -R 0:0 NVIDIA_PhysicsNeMo_accompanying_licenses /opt/nvidia/entrypoint.d/13-physicsnemo-versions.sh /opt/nvidia/physicsnemo_env.sh && pip install "Werkzeug>=3.0.3" && pip install "pyarrow>=14.0.1" && FILE="/etc/pip/constraint.txt" && if [ -f "$FILE" ]; then sed -i '/h11/d' "$FILE"; sed -i '/httpcore/d' "$FILE"; sed -i '/setuptools/d' "$FILE"; sed -i '/tornado/d' "$FILE"; sed -i '/jupyter_core/d' "$FILE"; sed -i '/protobuf/d' "$FILE"; sed -i '/pillow/d' "$FILE"; sed -i '/notebook/d' "$FILE"; sed -i '/jupyterlab/d' "$FILE"; sed -i '/mistune/d' "$FILE"; sed -i '/jupyter[_-]server/d' "$FILE"; sed -i '/^uv\b/d' "$FILE"; else echo "File not found: $FILE"; fi && pip install "h11>=0.16.0" "httpcore>=1.0.8" "tornado>=6.5.0" "jupyter_core>=5.8.1" "pillow>=12.1.1" && pip install "protobuf>=6.33.5" "nbconvert>=7.17.0" && pip install "notebook>=7.5.6" "jupyterlab>=4.5.7" "mistune>=3.2.1" "jupyter-server>=2.18.0" && pip install --upgrade "uv>=0.11.14" && pip install "setuptools>=80.10.2" "wheel>=0.46.2" # buildkit

ARG NVIDIA_PHYSICSNEMO_VERSION=26.08
ARG NVIDIA_PHYSICSNEMO_BUILD_ID=64216065

ENV NVIDIA_PRODUCT_NAME=NVIDIA PhysicsNeMo NVIDIA_PHYSICSNEMO_VERSION=26.08 NVIDIA_BUILD_ID=64216065

ENTRYPOINT ["/opt/nvidia/physicsnemo_env.sh"]

RUN /bin/bash -c python -m pip install --no-cache-dir plotly==6.3.0 dash==3.2.0 # buildkit

WORKDIR /workspace/project
