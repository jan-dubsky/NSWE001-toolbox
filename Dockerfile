FROM archlinux:latest

RUN mkdir nswe001 && mkdir nswe001/.lib
WORKDIR nswe001

# Update pacman database.
RUN pacman -Sy 

# Necessary sofware for the board & rest of this Dockerfile (git).
RUN pacman -S --noconfirm arm-none-eabi-gcc arm-none-eabi-binutils arm-none-eabi-newlib make openocd git 

# Clone STM library (HEL etc.)
RUN git clone --progress https://github.com/STMicroelectronics/STM32CubeF4.git .lib/stm32f4cube

RUN echo -e '\
# This is an STM32F4 discovery board with a single STM32F407VGT6 chip.\n\
# http://www.st.com/internet/evalboard/product/252419.jsp\n\
\n\
source [find interface/stlink-v2-1.cfg]\n\
\n\
transport select hla_swd\n\
\n\
source [find target/stm32f4x.cfg]\n\
\n\
reset_config srst_only\n' > /usr/share/openocd/scripts/board/stm32f4discovery-v2.1.cfg

# Those EnvVars are used by Makefile.
ENV ERS_ROOT=/nswe001/.lib
ENV ERS_TOOLCHAIN=${ERS_ROOT}/toolchain ERS_OPENOCD=${ERS_ROOT}/openocd ERS_ECLIPSE=${ERS_ROOT}/eclipse

# =============================================================================
# Mandatory part ends here, rest is just convenience software and setup.

ENV PS1='[\u@\h \W]$([ $? -ne 0 ] && echo "\[\e[01;31m\]")$\[\e[00m\] '
RUN pacman -S --noconfirm tmux vim htop less 

# Copy all sources we have to support development on host machine.
COPY . .
