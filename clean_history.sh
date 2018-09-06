wget http://repo1.maven.org/maven2/com/madgag/bfg/1.13.0/bfg-1.13.0.jar
git clone --mirror git@github.com:dynverse/dynguidelines.git
java -jar bfg-1.13.0.jar --delete-files methods_aggr.rda dynguidelines.git
cd dynguidelines.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push
rm bfg-1.13.0.jar