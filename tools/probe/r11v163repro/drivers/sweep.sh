# $1 = P|L ; $2 = corpora
source /tmp/v11u163_env.sh
if [ "$1" = P ]; then export SLANG_UHDM=/tmp/v11u163_bin/pris.bin; cd /tmp/wt_v11u163pris; else export SLANG_UHDM=/tmp/v11u163_bin/law.bin; cd /tmp/wt_v11u163; fi
tests/sweep.sh --jobs 3 --workdir /tmp/v11u163_sw$1 --corpus "$2" > /tmp/v11u163_sw$1_$(echo $2|tr ' ' _).log 2>&1
echo "rc=$?" >> /tmp/v11u163_sw$1_$(echo $2|tr ' ' _).log
