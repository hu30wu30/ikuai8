#!/bin/bash
# auto_install_ikuai8.sh — 自动下载并准备安装爱快(iKuai8)系统
# 前置确认：VNC/备份

set -e
trap 'echo "[ERROR] 脚本异常终止，请检查上述提示信息。"; exit 1' ERR

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'

# 0. 新增：确认 VNC 与备份
echo
read -p "你的服务器是否支持VNC远程连接，并不需要开机，并且电脑或者服务器已经备份好任何资料？(y/n): " ans0
case "$ans0" in
    [Yy])
        echo -e "${GREEN}已确认，继续执行...${NC}"
        ;;
    *)
        echo "已退出。"
        exit 0
        ;;
esac

# 1. 是否安装爱快系统
read -p "是否安装爱快系统？(y/n): " ans1
case "$ans1" in
    [Yy]) ;;
    *) echo "已退出。"; exit 0 ;;
esac

# 2. 是否下载 ISO 镜像
read -p "是否下载爱快的 ISO 镜像文件？(y/n): " ans2
case "$ans2" in
    [Yy]) ;;
    *) echo "已退出。"; exit 0 ;;
esac

# 3. 输入下载地址或选择默认
while true; do
    echo; echo -e "${YELLOW}请输入爱快 ISO 下载地址，直接回车则进入版本选择菜单：${NC}"
    read -e -i "" iso_url
    if [[ -z "$iso_url" ]]; then
        echo; echo "请选择要下载的版本："
        echo "  1) 32 位版本"
        echo "  2) 64 位版本"
        echo "  3) 自定义版本（返回上级输入地址）"
        echo "  4) 退出"
        read -p "请输入 1-4: " choice
        case "$choice" in
            1) iso_url="https://www.ikuai8.com/download.php?n=/3.x/iso/iKuai8_x32_3.7.20_Build202506041743.iso"; break ;;
            2) iso_url="https://www.ikuai8.com/download.php?n=/3.x/iso/iKuai8_x64_3.7.20_Build202506041743.iso"; break ;;
            3) continue ;;
            4) echo "已退出。"; exit 0 ;;
            *) echo -e "${RED}输入有误，请重新选择！${NC}" ;;
        esac
    else
        break
    fi
done

# 下载 ISO
echo; echo -e "${GREEN}开始下载：$iso_url${NC}"
if ! wget -c "$iso_url" -O ikuai8.iso; then
    echo -e "${RED}下载失败！请检查网络或链接有效性，然后重试。${NC}"
    exit 1
fi

# 5. 挂载并复制 boot
echo; echo -e "${GREEN}挂载 ISO 并复制启动文件...${NC}"
sudo mkdir -p /mnt
sudo umount /mnt 2>/dev/null || true
sudo mount -o loop ikuai8.iso /mnt
sudo cp -rpf /mnt/boot /
sudo umount /mnt
echo -e "${GREEN}启动文件已复制到 /boot${NC}"

# 6. 是否重启
echo; read -p "是否立即重启系统？(y/n): " ans6
case "$ans6" in
    [Yy])
        echo -e "${YELLOW}系统将在 3 秒后重启...${NC}"
        sleep 3
        sudo reboot
        ;;
    *)
        echo "已退出，下次重启即可进入爱快安装界面。"
        exit 0
        ;;
esac
