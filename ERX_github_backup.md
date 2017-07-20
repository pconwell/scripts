# Edgerouter X Backup Config to Github

Had a random thought - Would it be feasible to install a git client and run a crontab script to automatically upload your current config to github? The only issue I would see is /config/config.boot would be uploaded without the password hashed.

I guess you could do something like $ show configuration > /config/user-data/config.boot then $ git add && git commit && git push master origin, or whatever the appropriate commands would be.

Thoughts?

*****
EDIT: With guidance from u/zfa I was able to put together a relatively simple script. The script itself is pretty simple, but it was a pain in the ass trying to decipher github's API.

There are probably better ways to do this, but this is what I came up with.

**ONE**. Create a github account and then create a repository called 'edgerouter'

**TWO**. Then, you need to get the sha hash of your current backup file:

     hash='"'`curl  https://api.github.com/repos/pconwell/edgerouter/contents/config.boot.erxsfp | grep sha | cut -d '"' -f4`'"'

What this does is finds the hash for the 'current' version of your backup file on github (or if you are just starting out and your repo is empty - it does nothing). You have to have the current hash so you can tell github which file you are updating. Obviously you will want to replace this with your info (your username instead of 'pconwell' and if you give your repo a different name replace 'edgerouter' with whatever you call it).

**THREE**. Next, you need to get the newest config file from your router:

     temp64='"'`/bin/cli-shell-api showCfg --show-hide-secrets | base64 | tr -d '\n'`'"'

You want to be careful here because 'cli-shell-api showCfg' will show you your un-redacted configuration file. In other words, if you mess this part up you will post your passwords all over github. the '--show-hide-secrets' will redact your passwords. Github expects files to be uploaded in base 64 (at least through the API), so we convert it to base64 and strip out the new line characters. Other than that, nothing special.

**FOUR**. Now upload the config file to github:

     curl -i -X PUT -H 'Authorization: token YOUR-PRIVATE-GITHUB-API-KEY-HERE' -d '{"path": "config.bak", "message": "automated daily backup", "content": '"$temp64"', "sha": '"$hash"', "branch": "master"}' https://api.github.com/repos/pconwell/edgerouter/contents/config.boot.erxsfp

I'm not really sure what the 'path' variable does, but it seems to be necessary. You can see that the content of the API call is your config file from step 3 and the sha hash is the hash from step 2. Again, you will want to change your username and repo name to match your github file. Also, if you have a different router you may want to change the 'erxsfp' part, but that's personal preference.

That's all that's needed to back your config up to github. From there, you can run the script manually or set up a crontab to run it every so often. I'll probably set mine to daily, but you could make it whatever you feel like. If someone was feeling productive, you could probably even make a script that gets called every time the config file is updated. Maybe I'll look at that one day in the future. Maybe run the script when commit; save; is called?? I don't know.

*****
EDIT2: Not sure why reddit is butchering my code blocks...

*****
EDIT3: I started thinking about it and it was actually super easy. You just need to edit /etc/bash_completion.d/vyatta-cfg and towards the top-middle of the file you will see save () and something like

     save ()
     {
       if vyatta_cli_shell_api sessionChanged; then
         echo -e "Warning: you have uncommitted changes that will not be saved.\n"
       fi
       # return to top level.
       reset_edit_level
       # transform individual args into quoted strings
       local arg=''
       local save_cmd="${vyatta_sbindir}/vyatta-save-config.pl"
       for arg in "$@"; do
         save_cmd+=" '$arg'"
       done
       eval "sudo sg vyattacfg \"umask 0002 ; $save_cmd\""
       sync ; sync
       vyatta_cli_shell_api unmarkSessionUnsaved
       /config/user-data/github-backup.sh
      }

You just need to edit yours to add the last line '/config/user-data/github-backup.sh' (assuming you saved your script from above at that location with that name). That's it. Now every time you configure then commit; save;, you will automatically back up your config file to github. I'm really sure how changes are commited and saved in the gui, so this script may or may not work for changes made in the gui.
