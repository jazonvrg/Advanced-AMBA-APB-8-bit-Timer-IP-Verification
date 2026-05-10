class default_value_register_test extends base_test;

	virtual dut_if dut_vif;

	packet pkt = new();
	logic [7:0] rdata;

	function new(virtual dut_if dut_vif);
		super.new(dut_vif);	
		this.dut_vif = dut_vif;
	endfunction

	virtual task run_scenario();
		$display("==========================================================================");
		$display("================ TEST NAME: default_value_register_test ==================");
		$display("==========================================================================");

		repeat (256) begin
			//ITEM: Check the register TCR

			reset();

			if (pkt.randomize() with {addr == 8'h0;}) begin
				read(pkt.addr, rdata);
				$display("%0t: [testcase] Read addr = %b", $time, pkt.addr);
			end else begin
				$display("Randomization failed!");
			end
		end
		
		repeat (256) begin
			//ITEM: Check the register TSR

			reset();

			if (pkt.randomize() with {addr == 8'h1;}) begin
				read(pkt.addr, rdata);
				$display("%0t: [testcase] Read addr = %b", $time, pkt.addr);
			end else begin
				$display("Randomization failed!");
			end
		end
		
		repeat (256) begin
			//ITEM: Check the register TDR
		
			reset();

			if (pkt.randomize() with {addr == 8'h2;}) begin
			read(pkt.addr, rdata);
			$display("%0t: [testcase] Read addr = %b", $time, pkt.addr);
			end else begin
				$display("Randomization failed!");
			end
		end

		repeat (256) begin
			//ITEM: Check the register TIE

			reset();

			if (pkt.randomize() with {addr == 8'h3;}) begin
				read(pkt.addr, rdata);
				$display("%0t: [testcase] Read addr = %b", $time, pkt.addr);
			end else begin
				$display("Randomization failed!");
			end
		end
		
		repeat (256) begin
			//ITEM: Check the RESEVED register

			reset();

			if (pkt.randomize() with {addr > 8'h3;}) begin
				read(pkt.addr, rdata);
				$display("%0t: [testcase] Read addr = %b", $time, pkt.addr);
			end else begin
				$display("Randomization failed!");
			end
		end
	endtask

endclass
