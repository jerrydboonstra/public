set -x
if [ -r myapp.tgz ]
then
   rm -rf myapp.tgz
fi
cd ..
find myapp -type f | grep -v .svn | xargs tar czvf myapp.tgz -
ls -al myapp.tgz
tar tvf myapp.tgz
mv myapp.tgz myapp/.

