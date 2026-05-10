class tie_test extends base_test;

	virtual dut_if dut_vif;
	packet pkt = new();

	function new(virtual dut_if dut_vif);
		super.new(dut_vif);	
		this.dut_vif = dut_vif;
	endfunction

	virtual task run_scenario();
		$display("==========================================================================");
		$display("========================== TEST NAME: tie_test ===========================");
		$display("==========================================================================");

		repeat (256) begin
			//ITEM: Check the TIE behavior
		
			reset();

			if (pkt.randomize() with {addr == 8'h3;}) begin
				write(pkt.addr, pkt.data);
				$display("%0t: [testcase] Write addr = %b, data = %b", $time, pkt.addr, pkt.data);
				read(pkt.addr, pkt.data);
				$display("%0t: [testcase] Read addr = %b", $time, pkt.addr);
			end else begin
				$display("Randomization failed!");
			end
		end
	endtask

endclass
