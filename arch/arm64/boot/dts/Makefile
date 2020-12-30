# SPDX-License-Identifier: GPL-2.0

dtb-$(CONFIG_BOARD_J7VELTE) += exynos7870-j7velte_sea_open_00.dtb \
exynos7870-j7velte_sea_open_01.dtb \
exynos7870-j7velte_sea_open_03.dtb

dtb-$(CONFIG_BOARD_J7XELTE) += exynos7870-j7xelte_eur_open_00.dtb \
exynos7870-j7xelte_eur_open_01.dtb \
exynos7870-j7xelte_eur_open_02.dtb \
exynos7870-j7xelte_eur_open_03.dtb \
exynos7870-j7xelte_eur_open_04.dtb

dtb-$(CONFIG_BOARD_J6LTE) += exynos7870-j6lte_cis_ser_00.dtb \
exynos7870-j6lte_cis_ser_02.dtb


dtb-$(CONFIG_BOARD_ON7XELTE) += exynos7870-on7xelte_swa_open_00.dtb \
exynos7870-on7xelte_swa_open_01.dtb \
exynos7870-on7xelte_swa_open_02.dtb

targets += dtbs
DTB_LIST  := $(dtb-y) $(dtbo-y)
always    := $(DTB_LIST)

dtbs: $(addprefix $(obj)/, $(DTB_LIST))

clean-files := *.dtb*
