#!/bin/bash

BASE_DIR=$(cd $(dirname $0);cd ..;pwd)

ruby -I ${BASE_DIR}/lib ${BASE_DIR}/lib/osgi_config/list_generator.rb $@

# EOF
