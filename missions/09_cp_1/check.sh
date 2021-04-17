ENTRANCE="$(eval_gettext "\$GASH_HOME/Castle/Entrance")"
CABIN="$(eval_gettext "\$GASH_HOME/Forest/Cabin")"

check() {
  for I in $(seq 4)
  do
    local F="$(gettext "standard")_${I}"

    # Check that the standard file exists is in the cabin.
    if [ ! -f "${CABIN}/${F}" ]
    then
      echo "$(eval_gettext "The standard \$I is not in the cabin.")"
      return 1
    fi

    # Check that the standard is still in the entrance.
    if [ ! -f "${ENTRANCE}/${F}" ]
    then
      echo "$(eval_gettext "The standard \$I disapeared form the entrance.")"
      return 1
    fi

    # Check that the prefix of the first line is the name of the file.
    local P=$(cut -f 1 -d ' ' "${CABIN}/${F}")
    if [ "$(echo "${P}" | cut -f1 -d '#')" != "${F}" ]
    then
      echo "$(eval_gettext "The standard \$I in the cabin is not right.")"
      return 1
    fi

    # Same for the files in the entrance.
    P=$(cut -f 1 -d ' ' "${ENTRANCE}/${F}")
    if [ "$(echo "${P}" | cut -f1 -d '#')" != "${F}" ]
    then
      echo "$(eval_gettext "The standard \$I in the entrance is not right.")"
      return 1
    fi

    # Check that the suffix of the first line is the checksum.
    local S=$(cut -f 2 -d ' ' "${CABIN}/${F}")
    if [ "${S}" != "$(checksum "${P}")" ]
    then
      echo "$(eval_gettext "The standard \$I in the cabin is invalid.")"
      return 1
    fi

    # Same for the files in the entrance.
    S=$(cut -f 2 -d ' ' "${ENTRANCE}/${F}")
    if [ "${S}" != "$(checksum "${P}")" ]
    then
      echo "$(eval_gettext "The standard \$I in the entrance is invalid.")"
      return 1
    fi
  done

  return 0
}

if check
then
  unset -f check
  unset ENTRANCE CABIN
  true
else
  find "$GASH_HOME" -name "$(gettext "standard")_?" -type f -print0 | xargs -0 rm -f
  unset -f check
  unset ENTRANCE CABIN
  false
fi
