#!/bin/bash

# Set variables for backup locations.
ledger_file="$HOME/media/documents/finance/ledger/personal.journal"
backup_dir="$HOME/media/backups/finance/$(date -I)/"

# Make a backup.
if [[ ! -d $backup_dir ]]; then
    # Create a new backup directory and copy the files there.
    mkdir -p $backup_dir
    cp $ledger_file $backup_dir

    echo "Backed up $ledger_file to $backup_dir"
fi
