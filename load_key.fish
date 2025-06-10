#!/opt/homebrew/bin/fish

# by default list all the api keys, the installed and the not installed. the not installed have are ordered alphabetically and have a number to their left. if user presses a number that key is added to the .env and the list is updated and shown again. (additionally user can specify a range, specific with comma or * for all.

while true
	clear
	set -l API_DIR ~/.config/api

	## read set 1 of all available keys from ~/.config/api
	set -l AVAILABLE_KEYS
	for f in $API_DIR/*.env
		set key (basename $f .env)
		set AVAILABLE_KEYS $AVAILABLE_KEYS $key
	end

	## read set 2 of all keys currently present in .env (if any)
	set -l RAW_KEYS (grep -o '^[^=]*' .env 2>/dev/null)

	set -l CURRENT_KEYS
	for k in $RAW_KEYS
		set norm (string lower (string trim $k) | string replace '_key' '')
		set CURRENT_KEYS $CURRENT_KEYS $norm
	end
	set CURRENT_KEYS (printf "%s\n" $CURRENT_KEYS | sort)

	## filter and sort remaining keys directly
	set -l REMAINING_KEYS
	for k in (printf "%s\n" $AVAILABLE_KEYS | sort)
		if not contains $k $CURRENT_KEYS
			set REMAINING_KEYS $REMAINING_KEYS $k
		end
	end

	## exit if nothing left
	if test (count $REMAINING_KEYS) -eq 0
		echo "all api keys have already been added"
		break
	end

	## print numbered list
	for i in (seq (count $REMAINING_KEYS))
		echo "$i. $REMAINING_KEYS[$i]"
	end

	## show already installed
	printf "\nAlready in .env:\n"
	for k in $RAW_KEYS
		echo $k
	end

	## prompt user
	read -P "Enter key number to add (or q to quit):" choice

	if test "$choice" = "q"
		break
	end

	## add selected key
	set key $REMAINING_KEYS[$choice]
	cat "$API_DIR/$key.env" >> .env
end
