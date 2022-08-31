#!/usr/bin/bash

wikidb=$(kubectl get pods -n mediawiki -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}' | fgrep mediawiki-db | sed -e 's/'\n/'/g')
printf "\nWikidb= $wikidb\n"
kubectl exec -n mediawiki $wikidb -- free

wikiapp=$(kubectl get pods -n mediawiki -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}' | fgrep mediawiki-app | sed -e 's/'\n/'/g')
printf "\nWikiapp= $wikiapp\n"
kubectl exec -n mediawiki $wikiapp -- tar -zxvf wiki.tar.gz -C /root/temp
