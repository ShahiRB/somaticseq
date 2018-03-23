#!/bin/bash
# Use getopt instead of getopts for long options
# Consistent_Mates Inconsistent_Mates not included for training because BamSurgeon does not do those simulations. Also large number indicate short fragments.

set -e

OPTS=`getopt -o o: --long output-dir:,mutect:,mutect2:,indelocator:,strelka-snv:,strelka-indel:,varscan-snv:,varscan-indel:,jsm:,sniper:,vardict:,muse:,lofreq-snv:,lofreq-indel:,scalpel:,tnscope:,genome-reference:,cosmic:,dbsnp:,gatk:,tumor-bam:,normal-bam:,classifier-snv:,classifier-indel:,ada-r-script:,exclusion-region:,inclusion-region:,truth-indel:,truth-snv:,pass-threshold:,lowqual-threshold:,tumor-sample-name:,normal-sample-name:,keep-intermediates: -n 'SomaticSeq.Wrapper.sh'  -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

echo "$OPTS"
eval set -- "$OPTS"

MYDIR="$( cd "$( dirname "$0" )" && pwd )"

keep_intermediates=0
pass_threshold=0.5
lowqual_threshold=0.1
tumor_name='TUMOR'
normal_name='NORMAL'

while true; do
    case "$1" in
        -o | --output-dir )
            case "$2" in
                "") shift 2 ;;
                *)  merged_dir=$2 ; shift 2 ;;
            esac ;;

        --mutect )
            case "$2" in
                "") shift 2 ;;
                *)  mutect_vcf=$2 ; shift 2 ;;
            esac ;;

        --mutect2 )
            case "$2" in
                "") shift 2 ;;
                *)  mutect2_vcf=$2 ; shift 2 ;;
            esac ;;

        --strelka-snv )
            case "$2" in
                "") shift 2 ;;
                *)  strelka_snv_vcf=$2 ; shift 2 ;;
            esac ;;

        --strelka-indel )
            case "$2" in
                "") shift 2 ;;
                *)  strelka_indel_vcf=$2 ; shift 2 ;;
            esac ;;

        --indelocator )
            case "$2" in
                "") shift 2 ;;
                *)  indelocator_vcf=$2 ; shift 2 ;;
            esac ;;

        --varscan-snv )
            case "$2" in
                "") shift 2 ;;
                *)  varscan_vcf=$2 ; shift 2 ;;
            esac ;;

        --varscan-indel )
            case "$2" in
                "") shift 2 ;;
                *)  varscan_indel_vcf=$2 ; shift 2 ;;
            esac ;;

        --jsm )
            case "$2" in
                "") shift 2 ;;
                *)  jsm_vcf=$2 ; shift 2 ;;
            esac ;;

        --sniper )
            case "$2" in
                "") shift 2 ;;
                *)  sniper_vcf=$2 ; shift 2 ;;
            esac ;;

        --vardict )
            case "$2" in
                "") shift 2 ;;
                *)  vardict_vcf=$2 ; shift 2 ;;
            esac ;;

        --muse )
            case "$2" in
                "") shift 2 ;;
                *)  muse_vcf=$2 ; shift 2 ;;
            esac ;;

        --lofreq-snv )
            case "$2" in
                "") shift 2 ;;
                *)  lofreq_vcf=$2 ; shift 2 ;;
            esac ;;

        --lofreq-indel )
            case "$2" in
                "") shift 2 ;;
                *)  lofreq_indel_vcf=$2 ; shift 2 ;;
            esac ;;

        --scalpel )
            case "$2" in
                "") shift 2 ;;
                *)  scalpel_vcf=$2 ; shift 2 ;;
            esac ;;

        --tnscope )
            case "$2" in
                "") shift 2 ;;
                *)  tnscope_vcf=$2 ; shift 2 ;;
            esac ;;

        --genome-reference )
            case "$2" in
                "") shift 2 ;;
                *)  hg_ref=$2 ; shift 2 ;;
            esac ;;

        --cosmic )
            case "$2" in
                "") shift 2 ;;
                *)  cosmic=$2 ; shift 2 ;;
            esac ;;

        --dbsnp )
            case "$2" in
                "") shift 2 ;;
                *)  dbsnp=$2 ; shift 2 ;;
            esac ;;

        --gatk )
            case "$2" in
                "") shift 2 ;;
                *)  gatk=$2 ; shift 2 ;;
            esac ;;

        --tumor-bam )
            case "$2" in
                "") shift 2 ;;
                *)  tbam=$2 ; shift 2 ;;
            esac ;;

        --normal-bam )
            case "$2" in
                "") shift 2 ;;
                *)  nbam=$2 ; shift 2 ;;
            esac ;;

        --classifier-snv )
            case "$2" in
                "") shift 2 ;;
                *)  snpclassifier=$2 ; shift 2 ;;
            esac ;;

        --classifier-indel )
            case "$2" in
                "") shift 2 ;;
                *)  indelclassifier=$2 ; shift 2 ;;
            esac ;;

        --ada-r-script )
            case "$2" in
                "") shift 2 ;;
                *)  ada_r_script=$2 ; shift 2 ;;
            esac ;;

        --exclusion-region )
            case "$2" in
                "") shift 2 ;;
                *)  masked_region=$2 ; shift 2 ;;
            esac ;;

        --inclusion-region )
            case "$2" in
                "") shift 2 ;;
                *)  inclusion_region=$2 ; shift 2 ;;
            esac ;;

        --truth-indel )
            case "$2" in
                "") shift 2 ;;
                *)  indelgroundtruth=$2 ; shift 2 ;;
            esac ;;

        --truth-snv )
            case "$2" in
                "") shift 2 ;;
                *)  snpgroundtruth=$2 ; shift 2 ;;
            esac ;;

        --pass-threshold )
            case "$2" in
                "") shift 2 ;;
                *)  pass_threshold=$2 ; shift 2 ;;
            esac ;;

        --lowqual-threshold )
            case "$2" in
                "") shift 2 ;;
                *)  lowqual_threshold=$2 ; shift 2 ;;
            esac ;;

        --tumor-sample-name )
            case "$2" in
                "") shift 2 ;;
                *)  tumor_name=$2 ; shift 2 ;;
            esac ;;

        --normal-sample-name )
            case "$2" in
                "") shift 2 ;;
                *)  normal_name=$2 ; shift 2 ;;
            esac ;;

        --keep-intermediates )
             case "$2" in
                "") shift 2 ;;
                *)  keep_intermediates=$2 ; shift 2 ;;
            esac ;;

        -- ) shift; break ;;
        * ) break ;;
    esac
done

hg_dict=${hg_ref%\.fa*}.dict

if ! [[ -d ${merged_dir} ]];
then
    mkdir -p ${merged_dir}
fi


files_to_delete=''
#####     #####     #####     #####     #####     #####     #####     #####
# Modify the output of each tools into something that can be merged with GATK CombineVariants, just to be able to combine all the variant calls.
# MuTect
if [[ $mutect_vcf ]]; then
    $MYDIR/utilities/modify_MuTect.py -type snp -infile ${mutect_vcf} -outfile ${merged_dir}/mutect.snp.vcf -nbam ${nbam} -tbam ${tbam}
    files_to_delete="${merged_dir}/mutect.snp.vcf ${merged_dir}/mutect.snp.vcf.idx $files_to_delete"
fi

# If INDEL:
# Indelocator:
if [[ $indelocator_vcf ]]; then
    $MYDIR/utilities/modify_MuTect.py -type indel -infile ${indelocator_vcf} -outfile ${merged_dir}/indelocator.vcf -nbam ${nbam} -tbam ${tbam}
    files_to_delete="${merged_dir}/indelocator.vcf ${merged_dir}/indelocator.vcf.idx $files_to_delete"
fi

# MuTect2
if [[ $mutect2_vcf ]]; then
    $MYDIR/utilities/modify_MuTect2.py -infile $mutect2_vcf -snv ${merged_dir}/mutect.snp.vcf -indel ${merged_dir}/mutect.indel.vcf
    files_to_delete="${merged_dir}/mutect.snp.vcf ${merged_dir}/mutect.snp.vcf.idx ${merged_dir}/mutect.indel.vcf ${merged_dir}/mutect.indel.vcf.idx $files_to_delete"
fi

# VarScan2:
if [[ $varscan_vcf ]]; then
    $MYDIR/utilities/modify_VJSD.py -method VarScan2 -infile ${varscan_vcf} -outfile ${merged_dir}/varscan2.snp.vcf
    files_to_delete="${merged_dir}/varscan2.snp.vcf ${merged_dir}/varscan2.snp.vcf.idx $files_to_delete"
fi

# VarScan2:
if [[ $varscan_indel_vcf ]]; then
    $MYDIR/utilities/modify_VJSD.py -method VarScan2 -infile ${varscan_indel_vcf} -outfile ${merged_dir}/varscan2.indel.vcf
    files_to_delete="${merged_dir}/varscan2.indel.vcf ${merged_dir}/varscan2.indel.vcf.idx $files_to_delete"
fi

# JointSNVMix2:
if [[ $jsm_vcf ]] ; then
    $MYDIR/utilities/modify_VJSD.py -method JointSNVMix2  -infile ${jsm_vcf} -outfile ${merged_dir}/jsm.vcf
    files_to_delete="${merged_dir}/jsm.vcf ${merged_dir}/jsm.vcf.idx $files_to_delete"
fi

# SomaticSniper:
if [[ $sniper_vcf ]]; then
    $MYDIR/utilities/modify_VJSD.py -method SomaticSniper -infile ${sniper_vcf} -outfile ${merged_dir}/somaticsniper.vcf
    files_to_delete="${merged_dir}/somaticsniper.vcf ${merged_dir}/somaticsniper.vcf.idx $files_to_delete"
fi

# VarDict:
# Does both SNV and INDEL
if [[ $vardict_vcf ]]; then
    $MYDIR/utilities/modify_VarDict.py -infile ${vardict_vcf} -outfile ${merged_dir}/misorted.vardict.vcf
    $MYDIR/utilities/vcfsorter.pl ${hg_dict} ${merged_dir}/snp.misorted.vardict.vcf   > ${merged_dir}/snp.vardict.vcf
    $MYDIR/utilities/vcfsorter.pl ${hg_dict} ${merged_dir}/indel.misorted.vardict.vcf > ${merged_dir}/indel.vardict.vcf
    files_to_delete="${merged_dir}/snp.misorted.vardict.vcf ${merged_dir}/indel.misorted.vardict.vcf ${merged_dir}/snp.vardict.vcf ${merged_dir}/snp.vardict.vcf.idx ${merged_dir}/indel.vardict.vcf ${merged_dir}/indel.vardict.vcf.idx $files_to_delete"
fi

# MuSE:
if [[ $muse_vcf ]]; then
    $MYDIR/utilities/modify_VJSD.py -method MuSE  -infile ${muse_vcf} -outfile ${merged_dir}/muse.vcf
    files_to_delete="${merged_dir}/muse.vcf ${merged_dir}/muse.vcf.idx $files_to_delete"
fi

# LoFreq:
if [[ $lofreq_vcf ]]; then

    if [ ${lofreq_vcf: -3} == ".gz" ]; then
        gunzip -c $lofreq_vcf > ${merged_dir}/lofreq.snv.vcf
        lofreq_vcf="${merged_dir}/lofreq.snv.vcf"
        files_to_delete="${merged_dir}/lofreq.snv.vcf ${merged_dir}/lofreq.snv.vcf.idx $files_to_delete"
    fi
fi

# LoFreq:
if [[ $lofreq_indel_vcf ]]; then

    if [ ${lofreq_indel_vcf: -3} == ".gz" ]; then
        gunzip -c $lofreq_indel_vcf > ${merged_dir}/lofreq.indel.vcf
        lofreq_indel_vcf="${merged_dir}/lofreq.indel.vcf"
        files_to_delete="${merged_dir}/lofreq.indel.vcf ${merged_dir}/lofreq.indel.vcf.idx $files_to_delete"
    fi
fi


# Scalpel: just make copy so the .idx won't cause problem, or write permission of the original directory
# Scalpel:
if [[ $scalpel_vcf ]]; then
    cp $scalpel_vcf ${merged_dir}/scalpel.vcf
    files_to_delete="${merged_dir}/scalpel.vcf ${merged_dir}/scalpel.vcf.idx $files_to_delete"
fi


# Strelka: this is so that Strelka INDEL VCF does not clash with Scalpel, for reasons I haven't yet figured out.
if [[ $strelka_snv_vcf ]]; then
    $MYDIR/utilities/modify_Strelka.py -infile ${strelka_snv_vcf} -outfile ${merged_dir}/strelka.snv.vcf
    files_to_delete="${merged_dir}/strelka.snv.vcf ${merged_dir}/strelka.snv.vcf.idx $files_to_delete"
fi

if [[ $strelka_indel_vcf ]]; then
    $MYDIR/utilities/modify_Strelka.py -infile ${strelka_indel_vcf} -outfile ${merged_dir}/strelka.indel.vcf
    files_to_delete="${merged_dir}/strelka.indel.vcf ${merged_dir}/strelka.indel.vcf.idx $files_to_delete"
fi

# TNscope's VCF files are modeled after MuTect2's format:
if [[ $tnscope_vcf ]]; then
    $MYDIR/utilities/modify_MuTect2.py -infile $tnscope_vcf -snv ${merged_dir}/tnscope.snp.vcf -indel ${merged_dir}/tnscope.indel.vcf -tnscope
    files_to_delete="${merged_dir}/tnscope.snp.vcf ${merged_dir}/tnscope.snp.vcf.idx ${merged_dir}/tnscope.indel.vcf ${merged_dir}/tnscope.indel.vcf.idx $files_to_delete"
fi


# dbSNP
if [[ ${dbsnp} ]]; then
    dbsnp_input="-dbsnp ${dbsnp}"
fi

# COSMIC
if [[ ${cosmic} ]]; then
    cosmic_input="-cosmic ${cosmic}"
fi


#################### SNV ####################
if [[ -r ${merged_dir}/mutect.snp.vcf || -r ${merged_dir}/strelka.snv.vcf  || -r ${merged_dir}/somaticsniper.vcf || -r ${merged_dir}/jsm.vcf || -r ${merged_dir}/varscan2.snp.vcf || -r ${merged_dir}/muse.vcf || -r ${merged_dir}/snp.vardict.vcf || -r ${lofreq_vcf} ]]
then

    mergesnp=''
    all_snp=''
    for vcf in ${merged_dir}/mutect.snp.vcf ${merged_dir}/varscan2.snp.vcf ${merged_dir}/jsm.vcf ${merged_dir}/somaticsniper.vcf ${merged_dir}/snp.vardict.vcf ${merged_dir}/muse.vcf ${lofreq_vcf} ${merged_dir}/strelka.snv.vcf ${merged_dir}/tnscope.snp.vcf
    do
        if [[ -r $vcf ]]; then
            mergesnp="$mergesnp --variant $vcf"
            all_snp="$all_snp $vcf"
        fi
    done

    if [[ ${gatk} ]]; then
        java -Xmx4g -jar ${gatk} -T CombineVariants -R ${hg_ref} --setKey null --genotypemergeoption UNSORTED $mergesnp --out ${merged_dir}/CombineVariants_MVJSD.snp.vcf
    else
        $MYDIR/utilities/getUniqueVcfPositions.py -vcfs $all_snp -out /dev/stdout | $MYDIR/utilities/vcfsorter.pl ${hg_dict} - > ${merged_dir}/CombineVariants_MVJSD.snp.vcf
    fi

    files_to_delete="${merged_dir}/CombineVariants_MVJSD.snp.vcf ${merged_dir}/CombineVariants_MVJSD.snp.vcf.idx $files_to_delete"


    # See if each tool was used/exist
    if [[ ${mutect2_vcf} ]]; then
        mutect_input="-mutect ${merged_dir}/mutect.snp.vcf"
        tool_mutect="CGA"
    elif [[ ${mutect_vcf} ]]; then
        mutect_input="-mutect ${mutect_vcf}"
        tool_mutect="CGA"
    fi


    if [[ ${varscan_vcf} ]]; then
        varscan_input="-varscan ${varscan_vcf}"
        tool_varscan="VarScan2"
    fi


    if [[ ${jsm_vcf} ]]; then
        jsm_input="-jsm ${jsm_vcf}"
        tool_jsm="JointSNVMix2"
    fi


    if [[ ${sniper_vcf} ]]; then
        sniper_input="-sniper ${sniper_vcf}"
        tool_sniper="SomaticSniper"
    fi


    if [[ ${vardict_vcf} ]]; then
        vardict_input="-vardict ${merged_dir}/snp.vardict.vcf"
        tool_vardict="VarDict"
    fi


    if [[ ${muse_vcf} ]]; then
        muse_input="-muse ${muse_vcf}"
        tool_muse="MuSE"
    fi


    if [[ ${lofreq_vcf} ]]; then
        lofreq_input="-lofreq ${lofreq_vcf}"
        tool_lofreq="LoFreq"
    fi


    if [[ ${strelka_snv_vcf} ]]; then
        strelka_input="-strelka ${strelka_snv_vcf}"
        tool_strelka="Strelka"
    fi

    if [[ ${tnscope_vcf} ]]; then
        tnscope_input="-tnscope ${merged_dir}/tnscope.snp.vcf"
        tool_tnscope="TNscope"
    fi



    if [[ ${snpgroundtruth} ]]; then
        truth_input="-truth ${snpgroundtruth}"
    fi


    ##
    if [[ ${masked_region} ]]; then
        intersectBed -header -a ${merged_dir}/CombineVariants_MVJSD.snp.vcf -b ${masked_region} -v > ${merged_dir}/tmp.snp.vcf
        mv ${merged_dir}/tmp.snp.vcf ${merged_dir}/CombineVariants_MVJSD.snp.vcf
    fi

    if [[ ${inclusion_region} ]]; then
        intersectBed -header -a ${merged_dir}/CombineVariants_MVJSD.snp.vcf -b ${inclusion_region} | uniq > ${merged_dir}/tmp.snp.vcf
        mv ${merged_dir}/tmp.snp.vcf ${merged_dir}/CombineVariants_MVJSD.snp.vcf
    fi


    $MYDIR/SSeq_merged.vcf2tsv.py \
    -ref ${hg_ref} \
    -myvcf ${merged_dir}/CombineVariants_MVJSD.snp.vcf \
    $truth_input \
    $dbsnp_input \
    $cosmic_input \
    $mutect_input \
    $varscan_input \
    $jsm_input \
    $sniper_input \
    $vardict_input \
    $muse_input \
    $lofreq_input \
    $strelka_input \
    $tnscope_input \
    -mincaller 0.5 \
    -tbam ${tbam} \
    -nbam ${nbam} \
    -dedup \
    -outfile ${merged_dir}/Ensemble.sSNV.tsv


    # If a classifier is used, assume predictor.R, and do the prediction routine:
    if [[ ${snpclassifier} ]] && [[ ${ada_r_script} ]]; then
        "$ada_r_script" "$snpclassifier" "${merged_dir}/Ensemble.sSNV.tsv" "${merged_dir}/SSeq.Classified.sSNV.tsv"
        $MYDIR/SSeq_tsv2vcf.py -tsv ${merged_dir}/SSeq.Classified.sSNV.tsv -vcf ${merged_dir}/SSeq.Classified.sSNV.vcf -pass $pass_threshold -low $lowqual_threshold -N "$normal_name" -T "$tumor_name" -all -phred -tools $tool_mutect $tool_varscan $tool_jsm $tool_sniper $tool_vardict $tool_muse $tool_lofreq $tool_strelka $tool_tnscope

    # If ground truth is here, assume builder.R, and build a classifier
    elif [[ ${snpgroundtruth} ]] && [[ ${ada_r_script} ]]; then
        ${ada_r_script} "${merged_dir}/Ensemble.sSNV.tsv" Consistent_Mates Inconsistent_Mates

    # If no training and no classification, then make VCF by majority vote consensus:
    else
        $MYDIR/SSeq_tsv2vcf.py -tsv ${merged_dir}/Ensemble.sSNV.tsv -vcf ${merged_dir}/Consensus.sSNV.vcf -tools $tool_mutect $tool_varscan $tool_jsm $tool_sniper $tool_vardict $tool_muse $tool_lofreq $tool_strelka $tool_tnscope -N "$normal_name" -T "$tumor_name" -all
    fi

fi




#################### INDEL ####################
if [[ -r ${merged_dir}/mutect.indel.vcf || -r ${merged_dir}/strelka.indel.vcf || -r ${merged_dir}/varscan2.indel.vcf || -r ${merged_dir}/indel.vardict.vcf || -r ${lofreq_indel_vcf} || -r ${merged_dir}/indelocator.vcf || -r ${merged_dir}/scalpel.vcf ]]
then

    mergeindel=''
    all_indel=''
    for vcf in ${merged_dir}/mutect.indel.vcf ${merged_dir}/strelka.indel.vcf ${merged_dir}/indel.vardict.vcf ${merged_dir}/varscan2.indel.vcf ${lofreq_indel_vcf} ${merged_dir}/indelocator.vcf ${merged_dir}/scalpel.vcf
    do
        if [[ -r $vcf ]]; then
            mergeindel="$mergeindel --variant $vcf"
            all_indel="$all_indel $vcf"
        fi
    done

    if [[ ${gatk} ]]; then
        java -Xmx4g -jar ${gatk} -T CombineVariants -R ${hg_ref} --setKey null --genotypemergeoption UNSORTED $mergeindel --out ${merged_dir}/CombineVariants_MVJSD.indel.vcf
    else
        $MYDIR/utilities/getUniqueVcfPositions.py -vcfs $all_indel -out /dev/stdout | $MYDIR/utilities/vcfsorter.pl ${hg_dict} - > ${merged_dir}/CombineVariants_MVJSD.indel.vcf
    fi

    files_to_delete="${merged_dir}/CombineVariants_MVJSD.indel.vcf ${merged_dir}/CombineVariants_MVJSD.indel.vcf.idx $files_to_delete"


    ## MuTect2 will take precedence over Indelocator
    if [[ ${mutect2_vcf} ]]; then
        indelocator_input="-mutect ${merged_dir}/mutect.indel.vcf"
        tool_indelocator="CGA"
    elif [[ ${mutect_vcf} ]]; then
        indelocator_input="-mutect ${indelocator_vcf}"
        tool_indelocator="CGA"
    fi


    if [[ ${varscan_indel_vcf} ]]; then
        varscan_input="-varscan ${varscan_indel_vcf}"
        tool_varscan="VarScan2"
    fi


    if [[ ${vardict_vcf} ]]; then
        vardict_input="-vardict ${merged_dir}/indel.vardict.vcf"
        tool_vardict="VarDict"
    fi


    if [[ ${lofreq_indel_vcf} ]]; then
        lofreq_input="-lofreq ${lofreq_indel_vcf}"
        tool_lofreq="LoFreq"
    fi


    if [[ ${scalpel_vcf} ]]; then
        scalpel_input="-scalpel ${scalpel_vcf}"
        tool_scalpel="Scalpel"
    fi


    if [[ ${strelka_indel_vcf} ]]; then
        strelka_input="-strelka ${strelka_indel_vcf}"
        tool_strelka="Strelka"
    fi


    if [[ ${tnscope_vcf} ]]; then
        tnscope_input="-tnscope ${merged_dir}/tnscope.indel.vcf"
        tool_tnscope="TNscope"
    fi


    if [[ ${indelgroundtruth} ]]; then
        truth_input="-truth ${indelgroundtruth}"
    fi


    #
    if [[ ${masked_region} ]]; then
        intersectBed -header -a ${merged_dir}/CombineVariants_MVJSD.indel.vcf -b ${masked_region} -v > ${merged_dir}/tmp.indel.vcf
        mv ${merged_dir}/tmp.indel.vcf ${merged_dir}/CombineVariants_MVJSD.indel.vcf
    fi

    if [[ ${inclusion_region} ]]; then
        intersectBed -header -a ${merged_dir}/CombineVariants_MVJSD.indel.vcf -b ${inclusion_region} | uniq > ${merged_dir}/tmp.indel.vcf
        mv ${merged_dir}/tmp.indel.vcf ${merged_dir}/CombineVariants_MVJSD.indel.vcf
    fi

    $MYDIR/SSeq_merged.vcf2tsv.py \
    -ref ${hg_ref} \
    -myvcf ${merged_dir}/CombineVariants_MVJSD.indel.vcf \
    $truth_input \
    $dbsnp_input \
    $cosmic_input \
    $indelocator_input \
    $varscan_input \
    $vardict_input \
    $lofreq_input \
    $scalpel_input \
    $strelka_input \
    $tnscope_input \
    -mincaller 0.5 \
    -tbam ${tbam} \
    -nbam ${nbam} \
    -dedup \
    -outfile ${merged_dir}/Ensemble.sINDEL.tsv


    # If a classifier is used, use it:
    if [[ ${indelclassifier} ]] && [[ ${ada_r_script} ]]; then
        ${ada_r_script} "$indelclassifier" "${merged_dir}/Ensemble.sINDEL.tsv" "${merged_dir}/SSeq.Classified.sINDEL.tsv"
        $MYDIR/SSeq_tsv2vcf.py -tsv ${merged_dir}/SSeq.Classified.sINDEL.tsv -vcf ${merged_dir}/SSeq.Classified.sINDEL.vcf -pass $pass_threshold -low $lowqual_threshold -N "$normal_name" -T "$tumor_name" -all -phred -tools $tool_indelocator $tool_varscan $tool_vardict $tool_lofreq $tool_scalpel $tool_strelka $tool_tnscope

    # If ground truth is here, assume builder.R, and build a classifier
    elif [[ ${indelgroundtruth} ]] && [[ ${ada_r_script} ]]; then
        ${ada_r_script} "${merged_dir}/Ensemble.sINDEL.tsv" Strelka_QSS Strelka_TQSS Consistent_Mates Inconsistent_Mates

    # If no training and no classification, then make VCF by majority vote consensus:
    else
        $MYDIR/SSeq_tsv2vcf.py -tsv ${merged_dir}/Ensemble.sINDEL.tsv -vcf ${merged_dir}/Consensus.sINDEL.vcf -N "$normal_name" -T "$tumor_name" -tools $tool_indelocator $tool_varscan $tool_vardict $tool_lofreq $tool_scalpel $tool_strelka $tool_tnscope -all
    fi

fi

# Clean up intermediate files if wants to
if [ $keep_intermediates == 0 ]
then

    for file in ${files_to_delete}
    do
        if [[ -e $file ]]
        then
            rm -v $file
        fi
    done
    
fi
