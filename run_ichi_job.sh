#!/usr/bin/env bash
date_today=`date +%Y-%m-%d`
cd /Users/sgandhi/repos/rwork/
if [[  ! `grep "$date_today" doneFile` ]] ;then
    mv outfile.txt outfile_prev.txt
    /usr/local/bin/Rscript ichimoko_ikt.R
    if [ $? -eq 0 ];then
      echo -e 'mhane thano sinha huno hai!\n' | /usr/local/bin/gpg --no-tty --passphrase-fd 0 pd.gpg
      pd=`cat pd` && rm pd
      sort outfile.txt -o outfile.txt
      diff outfile_prev.txt outfile.txt > diff_yest.txt
      /Users/sgandhi/repos/mailsend/mailsend -f swapneshgandhi@gmail.com -smtp 173.194.202.108 -port 587 -starttls -auth-login -user swapneshgandhi@gmail.com -pass $pd \-t swapneshgandhi@gmail.com -sub "ichimoku report" -attach "/Users/sgandhi/repos/rwork/diff_yest.txt"
    fi
    if [ $? -eq 0 ];then
      echo $date_today >> doneFile

    fi
fi

