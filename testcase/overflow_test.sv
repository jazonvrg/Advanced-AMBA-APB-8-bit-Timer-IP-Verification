class overflow_test extends base_test;

	virtual dut_if dut_vif;
	
	packet pkt = new();
	logic [7:0] rdata;

	function new(virtual dut_if dut_vif);
		super.new(dut_vif);	
		this.dut_vif = dut_vif;
	endfunction

	virtual task run_scenario();
		$display("==========================================================================");
		$display("======================== TEST NAME: overflow_test ========================");
		$display("==========================================================================");

		//ITEM: Check the overflow behavior when CNT <= 255
		
		reset();

		if (pkt.randomize() with {addr == 8'h0; data[4:0] == {2'b00, 1'b0, 1'b0, 1'b1};}) begin
			write(pkt.addr, pkt.data);
			$display("%0t: [testcase] Write - addr = %b, data = %b", $time, pkt.addr, pkt.data);
		end else begin
			$display("Randomization failed!");
		end
		
		if (pkt.randomize() with {addr == 8'h1;}) begin
			repeat (61) @(posedge dut_vif.pclk);

			read(pkt.addr, rdata);
			$display("%0t: [testcase] Read addr = %b", $time, pkt.addr);
			
			//ITEM: Check the overflow behavior when CNT transfit from 255 -> 0 (CNT >= 0)
		
			read(pkt.addr, rdata);
			$display("%0t: [testcase] Read addr = %b", $time, pkt.addr);
		end else begin
			$display("Randomization failed!");
		end
			
		//ITEM: Check the overflow behavior when WRITE 1 TO CLEAR
		
		if (pkt.randomize() with {addr == 8'h1; data[0] == 1'b1;}) begin
			write(pkt.addr, pkt.data);
			$display("%0t: [testcase] Write - addr = %b, data = %b", $time, pkt.addr, pkt.data);
		end else begin
			$display("Randomization failed!");
		end
		
		if (pkt.randomize() with {addr == 8'h1;}) begin
			read(pkt.addr, rdata); 
			$display("%0t: [testcase] Read addr = %b", $time, pkt.addr);
		end else begin
			$display("Randomization failed!");
		end
	endtask

endclass
