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
KNAME=' AEON Q for J7velte By DAvinash97'
JOBS=$(($(nproc)+1))
echo -e "\nSetting Up Environment\n"

export CROSS_COMPILE=../../toolchain/bin/aarch64-linux-gnu-
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
if [ -f $IMAGE ]; then
rm $IMAGE
fi

if [ -f $GIMAGE ]; then
rm $GIMAGE
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

if [ -f AnyKernel/$NAME.zip ]; then
rm AnyKernel/$NAME.zip
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

if [ -f Flashable/$NAME.zip ]; then
rm Flashable/$NAME.zip
fi

if [ -f $NAME.zip ]; then
rm $NAME.zip
fi

if [ -f $NAME-AnyK.zip ]; then
rm $NAME-AnyK.zip
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

compile_dtb ()
{
echo -e "\nCompiling DTB\n"
./tools/dtbtool $DTS/ -o out/dtb
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
}

compile_aik ()
{
echo -e "\nMaking AIK Image\n"
if [ -f $IMAGE ]; then
    cp $IMAGE ./$CAIK/boot.img-zImage
    cp $CDTB ./$CAIK/boot.img-dt
    eval AIK/repackimg.sh
        if [ -f $NIMG ]; then
            cp -r $NIMG Flashable/boot.img
            cd Flashable
            zip -r9 $NAME *
            cp *.zip ../
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
            zip -r9 $NAME-AnyK *
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

LIST="J7Velte J7Xelte J6lte AIK AnyKernel Clean exit"
SNUM="1> J7Velte
2> J7Xelte
3> J6lte
4> Android Image Kitchen
5> AnyKernel
6> Clean Cache
7> Exit"
select DEVICE in $LIST
do
    case $DEVICE in 
        J7Velte)
            clean
            START=$(date +%M)
            echo -e "\nChosen $DEVICE\n"
            CONFIG=j7velte_defconfig
	        export LOCALVERSION=_$KNAME
            DTB="exynos7870-j7velte_sea_open_00.dtb exynos7870-j7velte_sea_open_01.dtb exynos7870-j7velte_sea_open_03.dtb"
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
                if [ -f $IMAGE ] && [ ! -f out/dtb ]; then 
                    compile_dtb
                else
                    echo -e "\nCompilation Failed\n"
                fi
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
                if [ -f $IMAGE ] && [ ! -f out/dtb ]; then 
                    compile_dtb
                else
                    echo -e "\nCompilation Failed\n"
                fi
        printf "$SNUM"
        ;;
        AIK)
            echo -e "\nChosen $DEVICE\n"
                if [ -f $IMAGE ]; then 
                    compile_aik
                else
                    echo -e "\nCheck Your Files if they exist\n"
                fi
        break
        ;;
        AnyKernel)
            echo -e "\nChosen $DEVICE\n"
                if [ -f AnyKernel3/Image ]; then
                compile_anyk
                else
                    echo -e "\nCheck Your Files if they exist\n"
                fi
        break
        ;;
        Clean)
            echo -e "\nChosen $DEVICE\n"
            echo -e "\nCleaning Up Previous Build"
            make O=out clean && make O=out mrproper
        ;;
        exit)
            break
        ;;
        *)
            echo -e "\nError: Invalid Input\n"
        ;;
    esac
total_time
done
