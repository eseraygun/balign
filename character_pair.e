note
	description: "A pair of characters."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	CHARACTER_PAIR

create
	make

feature -- Initialization

	make (f, s: CHARACTER) is
			-- Initialize `Current'.
		do
			first := f
			second := s
		end

feature -- Access

	first: CHARACTER

	second: CHARACTER

feature -- Measurement

feature -- Status report

feature -- Status setting

feature -- Cursor movement

feature -- Element change

	set_first (v: CHARACTER) is
			-- Let `first' be `v'.
		do
			first := v
		end

	set_second (v: CHARACTER) is
			-- Let `second' be `v'.
		do
			second := v
		end

feature -- Removal

feature -- Resizing

feature -- Transformation

feature -- Conversion

feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

feature -- Obsolete

feature -- Inapplicable

feature {NONE} -- Implementation

invariant
	invariant_clause: True -- Your invariant here

end
