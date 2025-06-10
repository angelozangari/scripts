# by default list all the api keys, the installed and the not installed. the not installed have are ordered alphabetically and have a number to their left. if user presses a number that key is added to the .env and the list is updated and shown again. (additionally user can specify a range, specific with comma or * for all.

set -l API_DIR ~/.config/api

## read set 1 of all available keys from ~/.config/api
for f in $API_DIR/*.env
	echo (basename $f .env)
end

## read set 2 of all keys currently present in .env (if any)
set -l CURRENT_KEYS (grep -o '^[^=]*' .env 2>/dev/null)
for i in (seq (count $CURRENT_KEYS))
	set CURRENT_KEYS[$i] (string lower $CURRENT_KEYS[$i] | string replace '_key' '')
end
set CURRENT_KEYS (printf "%s\n" $CURRENT_KEYS | sort)

## create set 3 = set 1 - set 2 of available but not yet added
for k in $AVAILABLE_KEYS
	if not contains $k $CURRENT_KEYS
		set REMAINING_KEYS $REMAINING_KEYS $k
	end
end
set -l REMAINING_KEYS (printf "%s\n" $REMAINING_KEYS | sort)

## print to stdout
### num. set 3
for i in (seq (count $REMAINING_KEYS))
	echo "$i. $REMAINING_KEYS[$i]"
end
### set 2
printf "\nAlready in .env:\n"
for k in $CURRENT_KEYS
	echo $k
end

## read number (later range, list and *)
read -p "Enter key number to add: " choice

## add specified keys to env
set key $REMAINING_KEYS[$choice]
cat "$API_DIR/$key.env" >> .env
