class tcr_test extends base_test;

	virtual dut_if dut_vif;
	
	packet pkt = new();
	logic [7:0] rdata;

	function new(virtual dut_if dut_vif);
		super.new(dut_vif);	
		this.dut_vif = dut_vif;
	endfunction

	virtual task run_scenario();
		$display("==========================================================================");
		$display("========================== TEST NAME: tcr_test ===========================");
		$display("==========================================================================");

		repeat (256) begin
			//ITEM: Check the TCR behavior

			reset();

			if (pkt.randomize() with {addr == 8'h0;}) begin
				write(pkt.addr, pkt.data);
				$display("%0t: [testcase] Write - addr = %b, data = %b", $time, pkt.addr, pkt.data);
				read(pkt.addr, rdata);
				$display("%0t: [testcase] Read addr = %b", $time, pkt.addr);
			end else begin
				$display("Randomization failed!");
			end
		end
	endtask

endclass
