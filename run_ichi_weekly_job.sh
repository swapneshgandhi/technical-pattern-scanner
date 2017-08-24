#!/usr/bin/env bash
date_today=`date +%Y-%m-%d`
cd /Users/sgandhi/repos/rwork/
if [[  ! `grep "$date_today" doneFile_weekly` ]] ;then
	  mv india_stock_list_outfile.txt india_stock_list_outfile_prev.txt
    /usr/local/bin/Rscript weekly_stock_signals.R
    if [ ! -z "india_stock_list_outfile.txt" ];then
      echo -e 'mhane thano sinha huno hai!\n' | /usr/local/bin/gpg --no-tty --passphrase-fd 0 pd.gpg
      pd=`cat pd` && rm pd
      /Users/sgandhi/repos/mailsend/mailsend -f swapneshgandhi@gmail.com -smtp 173.194.202.108 -port 587 -starttls -auth-login -user swapneshgandhi@gmail.com -pass $pd \-t swapneshgandhi@gmail.com -sub "ichimoku weekly report" -attach "/Users/sgandhi/repos/rwork/india_stock_list_outfile.txt"
    fi
    if [ $? -eq 0 ];then
      echo $date_today >> doneFile_weekly
    fi
fi

