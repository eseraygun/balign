indexing
	description: "Improved string class."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	ADVANCED_STRING

inherit
	STRING

create
	make,
	make_empty,
	make_filled,
	make_from_string,
	make_from_c,
	make_from_cil,
	make_from_chain,
	make_from_primary_chain,
	make_from_secondary_chain

feature {NONE} -- Initialization

	make_from_chain (v: CHAIN [CHARACTER]) is
			-- Create string from a character chain.
		local
			i: INTEGER
		do
			make_filled (' ', v.count)
			from i := 1 until i > count loop
				put (v [i], i)
				i := i + 1
			end
		end

	make_from_primary_chain (v: CHAIN [CHARACTER_PAIR]) is
			-- Create string from a character pair chain.
		local
			i: INTEGER
		do
			make_filled (' ', v.count)
			from i := 1 until i > count loop
				put (v [i].first, i)
				i := i + 1
			end
		end

	make_from_secondary_chain (v: CHAIN [CHARACTER_PAIR]) is
			-- Create string from a character pair chain.
		local
			i: INTEGER
		do
			make_filled (' ', v.count)
			from i := 1 until i > count loop
				put (v [i].second, i)
				i := i + 1
			end
		end

feature -- Access

	failed_character: CHARACTER

feature -- Status report

	all_in (s: SET [CHARACTER]): BOOLEAN is
			-- Are all characters in set `s'?
		local
			i: INTEGER
		do
			Result := True
			failed_character := ' '
			from
				i := 1
			until
				(i > count) or not Result
			loop
				if not s.has (item (i)) then
					Result := False
					failed_character := item (i)
				else
					i := i + 1
				end
			end
		end

feature -- Removal

	prune_whitespaces is
			-- Prune all whitespace characters (code <= 32).
		local
			i: INTEGER
		do
			from
				i := count
			until
				i = 0
			loop
				if item (i).code <= 32 then
					remove (i)
				end
				i := i - 1
			end
		end

feature -- Conversion

	to_chain: CHAIN [CHARACTER] is
			-- Convert string to character chain.
		local
			i: INTEGER
		do
			create {FIXED_LIST [CHARACTER]}Result.make (count)
			from
				i := 1
			until
				i > count
			loop
				Result.extend (item (i))
				i := i + 1
			end
		end

end
