if test -z $1; then olddate=2009_04_14; else olddate=$1; fi
if test -z $2; then prefix=`date -u +%Y%m%d%a`; else prefix=$2; fi
if test -z $ACE_ROOT; then ACE_ROOT=..; fi
if test -z $TAO_ROOT; then TAO_ROOT=${ACE_ROOT}/TAO; fi
if test -z $CIAO_ROOT; then CIAO_ROOT=${TAO_ROOT}/CIAO; fi
#
grep -h \!FIXED_BUGS_ONLY ${ACE_ROOT}/tests/*.lst ${ACE_ROOT}/bin/*.lst ${TAO_ROOT}/bin/*.lst ${CIAO_ROOT}/bin/*.lst | sed -e "s/^\([^\:]*\).*/\1/" | sed -e "s/\(\/run_test.pl\)\?\s*$//" > ${prefix}-Ignore.txt
#
perl ${ACE_ROOT}/bin/diff-builds.pl -r -D $olddate -D `date -u +%Y_%m_%d` | perl -ne 'print unless /^(\@\@|[ \-][a-zA-Z])/' | grep -v -f ${prefix}-Ignore.txt | tee ${prefix}-Builds.txt | grep '+[a-zA-Z]' | sort | uniq -c | sort -n -r -s | sort -k3 -r -s > ${prefix}-Tests.txt
perl ${ACE_ROOT}/bin/diff-builds.pl -D $olddate -D `date -u +%Y_%m_%d` | perl -ne 'print unless /^(\@\@|[ \-][a-zA-Z])/' | grep -v -f ${prefix}-Ignore.txt | grep '+[a-zA-Z]' | sort | uniq -c | sort -n -r -s > ${prefix}-Tests-NoTestRev.txt
