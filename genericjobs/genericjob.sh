#!/bin/sh
#
# Generic Job script which will get a stage bootstrap script from the
# Workflow Allocator
#

echo '====Start of genericjob.sh===='

date
printenv
pwd
ls -lR

# Used by bootstrap script to find files from this generic job
export WFS_PATH=`pwd`

# Create the get-file command
base64 -d <<EOF > $WFS_PATH/get-file
IyEvYmluL3NoCiMKIyBTY3JpcHQgZm9yIHVzZSB3aXRoaW4gYm9vdHN0cmFwIHNjcmlwdCB0byBn
ZXQgdGhlIERJRCwgUEZOLCBhbmQgUlNFCiMgb2YgYSBmaWxlIHRvIHByb2Nlc3Mgd2l0aGluIHRo
ZSBzdGFnZSBhc3NpZ25lZCB0byB0aGUgam9iLgojCiMgQm9vdHN0cmFwIHNjcmlwdHMgY2FuIGV4
ZWN1dGUgdGhpcyBzY3JpcHQgYXM6ICRXRlNfUEFUSC9nZXQtZmlsZQojCiMgRXJyb3IgbWVzc2Fn
ZXMgdG8gc3RkZXJyCiMgRElEIFBGTiBSU0UgdG8gc3Rkb3V0IG9uIG9uZSBsaW5lIGlmIGEgZmls
ZSBpcyBhdmFpbGFibGUKIwojIFRoaXMgc2NyaXB0IG11c3QgYmUgY29udmVydGVkIHRvIGJhc2U2
NCB3aXRoIHNvbWV0aGluZyBsaWtlIHRoZSBmb2xsb3dpbmcgCiMgYW5kIGluY2x1ZGVkIGluIHRo
ZSBoZXJlIGRvY3VtZW50IG5lYXIgdGhlIHN0YXJ0IG9mIGdlbmVyaWNqb2Iuc2ggOgojCiMgKG1h
Y09TKSBiYXNlNjQgLWIgNzYgZ2V0LWZpbGUgPiBnZXQtZmlsZS5iNjQKIyAoTGludXgpIGJhc2U2
NCAgICAgICBnZXQtZmlsZSA+IGdldC1maWxlLmI2NAoKaWYgWyAhIC1yICIkV0ZTX1BBVEgvd2Zz
LWdldC1maWxlLmpzb24iIF0gOyB0aGVuCiAgZWNobyAiJFdGU19QQVRIL3dmcy1nZXQtZmlsZS5q
c29uIG5vdCBmb3VuZCEiID4mMgogIGV4aXQgMgpmaQoKR0VUX0ZJTEVfVE1QPWBta3RlbXAgL3Rt
cC93ZnNfZ2V0X2ZpbGVfWFhYWFhYYAoKaHR0cF9jb2RlPWBjdXJsIFwKLS1oZWFkZXIgIlgtSm9i
aWQ6ICRKT0JTVUJKT0JJRCIgXAotLWhlYWRlciAiQWNjZXB0OiB0ZXh0L3BsYWluIiBcCi0tY2Fw
YXRoICR7WDUwOV9DRVJUSUZJQ0FURVM6LS9ldGMvZ3JpZC1zZWN1cml0eS9jZXJ0aWZpY2F0ZXMv
fSBcCi0tZGF0YSBAJFdGU19QQVRIL3dmcy1nZXQtZmlsZS5qc29uIFwKLS1vdXRwdXQgJEdFVF9G
SUxFX1RNUCBcCi0td3JpdGUtb3V0ICIle2h0dHBfY29kZX1cbiIgXApodHRwczovL3dmcy1kZXYu
ZHVuZS5oZXAuYWMudWsvd2ZhLWNnaWAKCmlmIFsgIiRodHRwX2NvZGUiID0gMjAwIF0gOyB0aGVu
CiBjYXQgJEdFVF9GSUxFX1RNUAogcmV0Y29kZT0wCmVsaWYgWyAiJGh0dHBfY29kZSIgPSA0MDQg
XSA7IHRoZW4gCiBlY2hvICJObyBmaWxlcyBhdmFpbGFibGUgZnJvbSB0aGlzIHN0YWdlIiA+JjIK
IHJldGNvZGU9MQplbHNlCiBlY2hvICJnZXRfZmlsZSByZWNlaXZlczoiID4mMgogY2F0ICRHRVRf
RklMRV9UTVAgPiYyCiBlY2hvICJnZXQtZmlsZSBmYWlscyB3aXRoIEhUVFAgY29kZSAkaHR0cF9j
b2RlIGZyb20gYWxsb2NhdG9yISIgPiYyCiByZXRjb2RlPTMKZmkKCnJtIC1mICRHRVRfRklMRV9U
TVAKZXhpdCAkcmV0Y29kZQo=
EOF
chmod +x $WFS_PATH/get-file

# Assemble values we will need 
export jobsub_id="$JOBSUBJOBID"
export site_name=${GLIDEIN_DUNESite:-XX_UNKNOWN}
export cpuinfo=`grep '^model name' /proc/cpuinfo | head -1 | cut -c14-`
export os_release=`head -1 /etc/redhat-release`
export hostname=`hostname`

# These are probably wrong: we should get them from the HTCondor job ad?
export rss_bytes=`expr ${GLIDEIN_MaxMemMBs:-4096} \* 1024 \* 1024`
export processors=${GLIDEIN_CPUs:-1}
export wall_seconds=${GLIDEIN_Max_Walltime:-86400}

# Check requirements are present

if [ ! -r "$X509_USER_PROXY" ] ; then
 echo "Cannot read X509_USER_PROXY file = $X509_USER_PROXY"
 exit
fi

curl --version
if [ $? -ne 0 ] ; then
 echo Failed running curl
 exit
fi

# Create the JSON to send to the allocator
cat <<EOF >wfs-get-stage.json
{
  "method"      : "get_stage",
  "jobsub_id"   : "$jobsub_id",
  "site_name"   : "$site_name",
  "cpuinfo"     : "$cpuinfo",
  "os_release"  : "$os_release",
  "hostname"    : "$hostname",
  "rss_bytes"   : $rss_bytes,
  "processors"  : $processors,
  "wall_seconds": $wall_seconds
}
EOF

echo '====start wfs-get-stage.json===='
cat wfs-get-stage.json
echo '====end wfs-get-stage.json===='

# Make the call to the Workflow Allocator
http_code=`curl \
--header "X-Jobid: $jobsub_id" \
--key $X509_USER_PROXY \
--cert $X509_USER_PROXY \
--cacert $X509_USER_PROXY \
--capath ${X509_CERTIFICATES:-/etc/grid-security/certificates/} \
--data @wfs-get-stage.json \
--output wfs-files.tar \
--write-out "%{http_code}\n" \
https://wfs.dune.hep.ac.uk/wfa-cgi`

if [ "$http_code" != "200" ] ; then
  echo "curl call to WFA fails with code $http_code"
  cat wfs-files.tar
  exit
fi

tar xvf wfs-files.tar

if [ -r wfs-env.sh ] ; then
  . ./wfs-env.sh
fi

# Run the bootstrap script
if [ -f wfs-bootstrap.sh ] ; then
  chmod +x wfs-bootstrap.sh

  echo '====Start wfs-bootstrap.sh===='
  cat wfs-bootstrap.sh
  echo '====End wfs-bootstrap.sh===='

  mkdir workspace
  echo '====Run wfs-bootstrap.sh===='
  ( cd workspace ; $WFS_PATH/wfs-bootstrap.sh )
  retval=$?
  echo '====After wfs-bootstrap.sh===='
else
  # How can this happen???
  echo No wfs-bootstrap.sh found
  retval=1
fi

# Make the lists of output files and files for the next stage
echo -n > wfs-outputs.txt
echo -n > wfs-next-stage-outputs.txt

cat wfs-output-patterns.txt | (
while read for_next_stage pattern
do  
  (
    cd workspace
    # $pattern is wildcard-expanded here - so a list of files
    for fn in $pattern
    do
      if [ -r "$fn" ] ; then
        echo "$fn" >> $WFS_PATH/wfs-outputs.txt
        if [ "$for_next_stage" = "True" ] ; then
          echo "$fn" >> $WFS_PATH/wfs-next-stage-outputs.txt    
        fi
      fi
    done
  )
done
)

next_stage_outputs=`echo \`sed 's/.*/"&"/' wfs-next-stage-outputs.txt\`|sed 's/ /,/g'`

# Just try the first RSE for now
rse=`echo $rse_list | cut -f1 -d' '`

for fn in `cat wfs-outputs.txt`
do
  echo "Would do rucio upload of $fn to $rse"
  echo "Metadata too? $fn.json"
  echo
done

# wfs-bootstrap.sh should produce a list of successfully processed input files
# and a list of files which still need to be processed by another job
processed_inputs=`echo \`sed 's/.*/"&"/' workspace/wfs-processed-inputs.txt\`|sed 's/ /,/g'`
unprocessed_inputs=`echo \`sed 's/.*/"&"/' workspace/wfs-unprocessed-inputs.txt\`|sed 's/ /,/g'`

cat <<EOF >wfs-return-results.json
{
  "method": "return_results",
  "wfs_job_id": $WFS_JOB_ID,
  "cookie": "$WFS_COOKIE",
  "processed_inputs": [$processed_inputs],
  "unprocessed_inputs": [$unprocessed_inputs],
  "next_stage_outputs": [$next_stage_outputs]
}
EOF

echo "=====Start wfs-return-results.json=="
cat wfs-return-results.json
echo "=====End wfs-return-results.json=="

http_code=`curl \
--capath ${X509_CERTIFICATES:-/etc/grid-security/certificates/} \
--data @wfs-return-results.json \
--output return-results.txt \
--write-out "%{http_code}\n" \
https://wfs.dune.hep.ac.uk/wfa-cgi`

echo "return_results returns HTTP code $http_code"
cat return-results.txt

echo '====End of genericjob.sh===='
