class packet;

	typedef enum logic {READ = 0, WRITE = 1} transfer_enum; 

	randc logic [7:0] addr;
	randc logic [7:0] data;
	transfer_enum transfer;	

	function new();
	endfunction

endclass
