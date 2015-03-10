OUTBASE='/tmp/evaluation/'
DATASETS='varsim other_dataset'.split()
GNUTIME="/usr/bin/time -lp" # "/usr/bin/time -v" if Linux
TOOLS="svest clever".split()
#################################################
# standard python functions

import re
import os


###########
# This creation of directories is just for testing 
# we will have real paths to files and do not need tou create them.
# remove this after the fist time you execute snakemake.
# Here we create some initial file presenting the reads 
# of some data set just to make this template work, 
# read files should exist on UPPMAX anyway

os.popen("mkdir -p /tmp/varsim")
os.popen("touch /tmp/varsim/reads.fastq")
os.popen("touch /tmp/varsim/ref.fasta")
os.popen("touch /tmp/varsim/truth.vcf")
os.popen("mkdir -p /tmp/other_dataset")
os.popen("touch /tmp/other_dataset/reads.fastq")
os.popen("touch /tmp/other_dataset/ref.fasta")
os.popen("touch /tmp/other_dataset/truth.vcf")
##############
     


def clever_out_to_VCF(csv_file):
    """
        This is a dummy function to illustrate that we can transform 
        any sv-callers output format to VCF, handy!
    """
    pass

def other_sv_tool_out_to_VCF():
    """
        This is a dummy function to illustrate that we can transform 
        any sv-callers output format to VCF, handy!
    """
    pass

def get_memory_and_runtime_from_GNUTIME():
    pass

def evaluate_vcf(vcf_file,true_variants):
    """
        This could be done in a function (optimistic)
        or ve have a separate module for this that
        we import and run here
    """
    pass

#####################################


#TODO: We might want to add a rule that produces a vcf
# of the true variants in case they are not given

rule all:
    input:
        OUTBASE+"performance_table.tex",        
        OUTBASE+"quality_table.tex"



rule process_VARSIM:
    """
        This rule will process the raw data and obtain 
        all neccessary files as input to the sv-tools.
        An example would be to here align the reads and get
        a bam file if a sv-tool requires it. We could also run
        various logging stats here
    """
    input: fastq='/tmp/varsim/reads.fastq', ref='/tmp/varsim/ref.fasta' 
    output: folder=OUTBASE+"datasets/varsim/"
    run:
        # dummy fcn here, replace with real processing
        # run shell commands
        shell("mkdir -p {output.folder}") 
        # or python
        if not os.path.exists(output.folder):
            os.makedirs(output.folder)


rule process_OTHER_DATASET:
    """
        This rule will process the raw data and obtain 
        all neccessary files as input to the sv-tools.
        An example would be to here align the reads and get
        a bam file if a sv-tool requires it. We could also run
        various logging stats here
    """
    input: fastq='/tmp/other_dataset/reads.fastq', ref='/tmp/other_dataset/ref.fasta'
    output: folder=OUTBASE+"datasets/other_dataset/"
    run:
        # dummy fcn here, replace with real processing
        # run shell commands
        shell("mkdir -p {output.folder}") 
        # or python
        print(output.folder)
        if not os.path.exists(output.folder):
            os.makedirs(output.folder)



rule SVEST:
    input: folder=OUTBASE+"datasets/{dataset}/"
    output: vcf=OUTBASE+"results/{dataset}.svest.vcf", stderr=OUTBASE+"results/{dataset}.svest.stderr", stdout=OUTBASE+"results/{dataset}.svest.stdout"
    run:
        # dummy instruction, run the actual commands to 
        # execute svest here
        shell(" {GNUTIME} echo svest on: {input.folder} 1> {output.stdout} 2> {output.stderr}")
        shell("touch {output.vcf}")

rule CLEVER:
    input: folder=OUTBASE+"datasets/{dataset}/"
    output: csv=OUTBASE+"results/{dataset}.clever.csv", stderr=OUTBASE+"results/{dataset}.clever.stderr", stdout=OUTBASE+"results/{dataset}.clever.stdout"
    run:
        # some python processing
        for i in range(10):
            pass
        shell(" {GNUTIME} echo clever on: {input.folder} 1> {output.stdout} 2> {output.stderr}")
        shell("touch {output.csv}")

rule CLEVER_TO_VCF:
    input: folder=OUTBASE+"results/{dataset}.clever.csv"
    output: vcf=OUTBASE+"results/{dataset}.clever.vcf"
    run:
        # replace with actual converter
        clever_out_to_VCF("{{input.folder}}")
        shell(" cp {input.folder} {output.vcf}")


rule EVALUATE_VCF:
    input: vcf=OUTBASE+"results/{dataset}.{tool}.vcf", true="/tmp/{dataset}/truth.vcf"
    output: eval_file=OUTBASE+"results/{dataset}.{tool}.results"
    run:
        # replace with actual evaluator
        evaluate_vcf("{{input.vcf}}","{{input.true}}")
        shell(" touch {output.eval_file}")


rule TIME_AND_MEM_TABLE:
    input: expand(OUTBASE+"results/{dataset}.{tool}.stderr", tool=TOOLS, dataset=DATASETS)
    output: table=OUTBASE+"performance_table.tex"
    run:
        get_memory_and_runtime_from_GNUTIME()
        shell("touch {output.table}")   

# rule performace_latex_table:
#     input: expand(OUTBASE+"{tool}_{dataset}/time_and_mem.txt", tool=TOOLS, dataset=DATASETS)
#     output: table=OUTBASE+"performance_table.tex"
#     run:
#         shell("touch {output.table}") 


rule RESULTS_TABLE:
    input: expand(OUTBASE+"results/{dataset}.{tool}.results", tool=TOOLS, dataset=DATASETS)
    output: table=OUTBASE+"quality_table.tex"
    run:
        shell("touch {output.table}") 
