indexing
	description: "8-bit character sets implemented using boolean arrays."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	CHARACTER_8_SET

inherit
	SUBSET [CHARACTER_8]

create
	make

feature {NONE} -- Initialization

	make is
			-- Initialize set.
		do
			create bits.make ({CHARACTER_8}.min_value, {CHARACTER_8}.max_value)
		end

feature -- Measurement

	count: INTEGER is
			-- Number of items.
		local
			i: INTEGER
		do
			from
				i := {CHARACTER_8}.min_value
			until
				i > {CHARACTER_8}.max_value
			loop
				if bits [i] then
					Result := Result + 1
				end
				i := i + 1
			end
		end

feature -- Status report

	has (v: CHARACTER_8): BOOLEAN is
			-- Does structure include `v'?
		do
			Result := bits [v.code]
		end

	extendible: BOOLEAN is
			-- May new items be added?
		do
			Result := True
		end

	prunable: BOOLEAN is
			-- May items be removed?
		do
			Result := True
		end

	is_empty: BOOLEAN is
			-- Is there no element?
		do
			Result := count = 0
		end

	is_subset (other: SUBSET [CHARACTER_8]): BOOLEAN is
			-- Is current set a subset of `other'?
		local
			i: INTEGER
		do
			Result := True
			from
				i := {CHARACTER_8}.min_value
			until
				(i > {CHARACTER_8}.max_value) or not Result
			loop
				if has (i.to_character_8) and not other.has (i.to_character_8) then
					Result := False
				else
					i := i + 1
				end
			end
		end

feature -- Element change

	extend, put (v: CHARACTER_8) is
			-- Ensure that set includes `v'.
		do
			bits [v.code] := True
		end

	merge (other: CONTAINER [CHARACTER_8]) is
			-- Add all items of `other'.
		local
			l: LINEAR [CHARACTER_8]
		do
			l := other.linear_representation
			from
				l.start
			until
				l.off
			loop
				put (l.item)
				l.forth
			end
		end

feature -- Removal

	prune (v: CHARACTER_8) is
			-- Remove `v' if present.
		do
			bits [v.code] := False
		end

	wipe_out is
			-- Remove all items.
		local
			i: INTEGER
		do
			from
				i := {CHARACTER_8}.min_value
			until
				i > {CHARACTER_8}.max_value
			loop
				bits [i] := False
				i := i + 1
			end
		end

feature -- Conversion

	linear_representation: LINEAR [CHARACTER_8] is
			-- Representation as a linear structure.
		local
			i: INTEGER
			r: ARRAYED_LIST [CHARACTER_8]
		do
			create r.make (1)
			from
				i := {CHARACTER_8}.min_value
			until
				i > {CHARACTER_8}.max_value
			loop
				r.force (i.to_character_8)
				i := i + 1
			end
			Result := r
		end

feature -- Duplication

	duplicate (n: INTEGER): like Current is
			-- New structure containing min (`n', `count')
			-- items from current structure.
		local
			i, m: INTEGER
		do
			create Result.make
			m := 0
			from
				i := {CHARACTER_8}.min_value
			until
				(i > {CHARACTER_8}.max_value) or (m = n)
			loop
				if has (i.to_character_8) then
					Result.put (i.to_character_8)
					m := m + 1
				end
				i := i + 1
			end
		end

feature -- Basic operations

	intersect (other: SUBSET [CHARACTER_8]) is
			-- Remove all items not in `other'.
		local
			i: INTEGER
		do
			from
				i := {CHARACTER_8}.min_value
			until
				i > {CHARACTER_8}.max_value
			loop
				if not other.has (i.to_character_8) then
					bits [i] := False
				end
				i := i + 1
			end
		end

	subtract (other: SUBSET [CHARACTER_8]) is
			-- Remove all items also in `other'.
		local
			i: INTEGER
		do
			from
				i := {CHARACTER_8}.min_value
			until
				i > {CHARACTER_8}.max_value
			loop
				if other.has (i.to_character_8) then
					bits [i] := False
				end
				i := i + 1
			end
		end

feature {NONE} -- Implementation

	bits: ARRAY [BOOLEAN]
			-- Boolean array storing existence information.

end
