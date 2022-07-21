#!/bin/bash

model=$(ioreg -c IOPlatformExpertDevice | grep model | cut -d\" -f4)


if [[ $model == *"Book"* ]]; then
  echo "<result>Laptop</result>"

    else
        echo "<result>Desktop</result>"
fi

exit 0