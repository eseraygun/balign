note
	description: "File not found exception."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	FILE_NOT_FOUND

inherit
	DEVELOPER_EXCEPTION
		redefine
			internal_meaning
		end

feature {NONE} -- Access

	internal_meaning: STRING is
		once
			Result := "File not found."
		end

end
