note
	description: "Undefined value exception."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	UNDEFINED_VALUE

inherit
	DEVELOPER_EXCEPTION
		redefine
			internal_meaning
		end

feature {NONE} -- ACCESS

	internal_meaning: STRING is
		once
			Result := "Undefined value."
		end
end
