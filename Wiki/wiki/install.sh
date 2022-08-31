#!/bin/bash

# Create Namespace
#kubectl apply -f mediawiki-namespace.yaml

# Create Database PV/PVC
#kubectl apply -f mediawiki-db-pvc.yaml

# Create Wki-App PV/PVC
#kubectl apply -f mediawiki-app-pvc.yaml

# Launch Database Container
#kubectl apply -f mediawiki-db.yaml

# Launch Wiki-App Container
#kubectl apply -f mediawiki-app.yaml

# Store container names as environment variables
#wikidb=$(kubectl get pods -n mediawiki -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}' | fgrep mediawiki-db | sed -e 's/'\n/'/g')
#wikiapp=$(kubectl get pods -n mediawiki -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}' | fgrep mediawiki-app | sed -e 's/'\n/'/g')

# Copy Wiki Content to Wiki-App Container
#kubectl cp wiki.tar.gz -n mediawiki <mediawiki-app container>:/root

# Untar content into /var/www/html directory in mediawiki app container
kubectl exec -n mediawiki $wikiapp -- tar -zxvf /root/wiki.tar.gz -C /var/www/html

# Remove mediawiki tar file from container
#kubectl exec -n mediawiki $wikiapp -- rm /root/wiki.tar.gz

# Copy DB Content to Database Container
#kubectl cp backup.sql -n mediawiki <mediawiki-db container>:/root

# Import database content into database on mediawiki db container
#kubectl exec -n mediawiki $wikiapp -- mysql --user=wikiuser --paswword=wikipass wiki < /root/backup.sql

