#!/bin/bash

FMT_ERR=$(terraform fmt -list -write=false lib/pentagon/default/vpc)
if [ "$(FMT_ERR)" != "" ];
  then
  echo "misformatted files (run 'terraform fmt .' to fix):" $(FMT_ERR)
  exit 1
fi
