#!/bin/bash
# Script by DAvinash97
# Feel free to use, make sure to add proper credits

IMAGE=out/arch/arm64/boot/Image;
GIMAGE=$IMAGE.gz
DTS=out/arch/arm64/boot/dts;
CDTB=out/dtb;
CAIK=AIK/split_img;
NIMG='AIK/image-new.img';
NAME='AEON-Q'; #FOR ZIP_NAME
KNAME=' AEON Q By DAvinash97'
JOBS=$(($(nproc)+1))
echo -e "\nSetting Up Environment\n"

export CROSS_COMPILE=../../toolchain/bin/aarch64-none-linux-gnu-
export CC=../../clang/bin/clang
export CLANG_TRIPLE=../../clang/bin/aarch64-linux-gnu-
export ARCH=arm64
export ANDROID_MAJOR_VERSION=q
export ANDROID_VERSION=100000
export PLATFORM_VERSION=10.0.0
export USE_CCACHE=1

if [ ! -d AIK ]; then
exit
fi

if [ ! -d AnyKernel3 ]; then
exit
fi

if [ -d Flashable ]; then
    if [ -d Flashable/META-INF ]; then
        if [ -d Flashable/META-INF/com ]; then
            if [ -d Flashable/META-INF/com/google ]; then
                if [ -d Flashable/META-INF/com/google/android ]; then
                    if [ -f Flashable/META-INF/com/google/android/update-binary ]; then
                        if [ ! -f Flashable/META-INF/com/google/android/updater-script ]; then
                            exit
                        fi
                    else
                        exit
                    fi
                else
                    exit
                fi
            else
                exit
            fi
         else
            exit
         fi
    else
         exit
    fi
else
exit
fi

clean ()
{
if [ -f $IMAGE* ]; then
rm $IMAGE*
fi

if [ -d $DTS ]; then
rm -rf $DTS
fi

if [ -f $CDTB ]; then
rm $CDTB
fi

if [ -f $NIMG ]; then
rm $NIMG
fi

if [ -f AnyKernel/*.zip ]; then
rm AnyKernel/*.zip
fi

if [ -f AnyKernel/Image ]; then
rm AnyKernel/Image
fi

if [ -f AnyKernel/dtb ]; then
rm AnyKernel/dtb
fi

if [ -f $NIMG ]; then
rm $NIMG
fi

if [ -f Flashable/*.img ]; then
rm Flashable/*.img
fi

if [ -f Flashable/*.zip ]; then
rm Flashable/*.zip
fi

if [ -f ./$CAIK/boot.img-zImage ]; then
rm ./$CAIK/boot.img-zImage
fi

if [ -f ./$CAIK/boot.img-dt ]; then
rm ./$CAIK/boot.img-dt
fi
}

clear

if [ ! -d out ]; then
mkdir out
cp -r firmware out/firmware
fi

if [ -f *.zip ]; then
rm *.zip
fi

OTHERS="AIK AnyKernel exit"
COMPILE ()
{
select CHOICE in $OTHERS
do
	case $CHOICE in
		AIK)
			compile_aik
			break
		;;
		AnyKernel)
			compile_anyk
			break
		;;
		exit)
			break
		;;
        	*)
            		echo -e "\nError: Invalid Input\n"
        	;;
	esac
done
}

compile_dtb ()
{
echo -e "\nCompiling DTB\n"
./tools/dtbtool $DTS/ -o out/dtb
total_time
	if [ -f $IMAGE ] && [ -f out/dtb ]; then
		COMPILE
	fi
}

compile_kernel ()
{
echo -e "\nCompiling\n"
echo -e "\nMaking $CONFIG\n"
make O=out $CONFIG
echo -e "\nMaking DTB\n"
make O=out $DTB
echo -e "\nCompiling zImage\n"
make O=out -j$(($(nproc) + 1))
    if [ -f $IMAGE ] && [ ! -f out/dtb ]; then 
        compile_dtb
    else
        echo -e "\nCompilation Failed\n"
    fi
}

compile_aik ()
{
echo -e "\nMaking AIK Image\n"
if [ -f $IMAGE ]; then
    cp $IMAGE ./$CAIK/boot.img-zImage
    cp $CDTB ./$CAIK/boot.img-dt
    eval AIK/repackimg.sh
        if [ -f $NIMG ]; then
            cp -r $NIMG Flashable/$DEVICE.img
            cd Flashable
            zip -r9 $NAME-$DEVICE *
            mv *.zip ../
            cd ..
        fi
else
echo -e "Image not found"
fi
}

compile_anyk ()
{
if [ -f $IMAGE ]; then
    cp $IMAGE ./AnyKernel3/
    cp $CDTB ./AnyKernel3/
        if [ -f AnyKernel3/Image ]; then
            cd AnyKernel3
            zip -r9 $NAME-$DEVICE-AnyK *
            cp *.zip ../
            cd ..
        fi
fi
}

total_time ()
{
END=$(date +%M)
DIFF=$(( $END - $START ))
echo -e "\nIt took $DIFF minutes"
}

LIST="J7Velte J7Xelte J6lte On7xelte Other Clean exit"
SNUM="1) J7Velte
2) J7Xelte
3) J6lte
4) On7xelte
5) Other
6) Clean Cache
7) Exit"
select DEVICE in $LIST
do
    case $DEVICE in 
        J7Velte)
            clean
            START=$(date +%M)
            echo -e "\nChosen $DEVICE\n"
            CONFIG=j7velte_defconfig
	        export LOCALVERSION=_$KNAME
                select VARIANT in J701F J701M exit
                    do
	                    case $VARIANT in
		                    J701F)
                                    echo "Making for $VARIANT"
	                                export CONFIG_BOARD_J7VELTE=y
                                    DEVICE=J701F
                                    DTB="exynos7870-j7velte_sea_open_00.dtb exynos7870-j7velte_sea_open_01.dtb exynos7870-j7velte_sea_open_03.dtb"
			                    break
		                    ;;
		                    J701M)
                                    echo "Making for $VARIANT"
	                                export CONFIG_BOARD_J7VELTE_M=y
                                    DEVICE=J701M
                                    DTB="exynos7870-j7velte_ltn_dtv_01.dtb exynos7870-j7velte_ltn_dtv_03.dtb"
			                    break
		                    ;;
		                    exit)
			                    break
		                    ;;
                            *)
                                		echo -e "\nError: Invalid Input\n"
                            	;;
	                    esac
                    done
                compile_kernel
                if [ -f $IMAGE ] && [ ! -f out/dtb ]; then 
                    compile_dtb
                else
                    echo -e "\nCompilation Failed\n"
                fi
        printf "$SNUM"
        ;;
        J7Xelte)
            clean
            START=$(date +%M)
            echo -e "\nChosen $DEVICE\n"
            CONFIG=j7xelte_defconfig
	        export LOCALVERSION=_$KNAME
            DTB="exynos7870-j7xelte_eur_open_00.dtb exynos7870-j7xelte_eur_open_01.dtb exynos7870-j7xelte_eur_open_02.dtb exynos7870-j7xelte_eur_open_03.dtb exynos7870-j7xelte_eur_open_04.dtb"
            compile_kernel
        printf "$SNUM"
        ;;
        J6lte)
            clean
            START=$(date +%M)
            echo -e "\nChosen $DEVICE\n"
            CONFIG=j6lte_defconfig
	        export LOCALVERSION=_$KNAME
            DTB="exynos7870-j6lte_cis_ser_00.dtb exynos7870-j6lte_cis_ser_02.dtb"
            compile_kernel
        printf "$SNUM"
        ;;
        On7xelte)
            clean
            START=$(date +%M)
            echo -e "\nChosen $DEVICE\n"
            CONFIG=on7xelte_defconfig
	        export LOCALVERSION=_$KNAME
            DTB="exynos7870-on7xelte_swa_open_00.dtb exynos7870-on7xelte_swa_open_01.dtb exynos7870-on7xelte_swa_open_02.dtb"
            compile_kernel
        printf "$SNUM"
        ;;	
        Other)
		COMPILE	
        printf "$SNUM"
        ;;
        Clean)
            echo -e "\nChosen $DEVICE\n"
            echo -e "\nCleaning Up Previous Build"
            make O=out clean && make O=out mrproper
            if [ -f AEON*.zip ]; then
                rm AEON*.zip
            fi
        ;;
        exit)
            break
        ;;
        *)
            echo -e "\nError: Invalid Input\n"
        ;;
    esac
done
