class count_up_test extends base_test;

	virtual dut_if dut_vif;
	
	time T1, T2;
	
	packet pkt = new();
	logic [7:0] rdata;

	function new(virtual dut_if dut_vif);
		super.new(dut_vif);	
		this.dut_vif = dut_vif;
	endfunction

	virtual task run_scenario();
		$display("==========================================================================");
		$display("======================== TEST NAME: count_up_test ========================");
		$display("==========================================================================");

		repeat (256) begin	
			//ITEM: Check the count up behavior

			reset();
			
			if (pkt.randomize() with {addr == 8'h3; data[0] == {1'b1};}) begin
				write(pkt.addr, pkt.data);
				$display("%0t: [testcase] Write - addr = %b, data = %b", $time, pkt.addr, pkt.data);
			end else begin
				$display("Randomization failed!");
			end

			if (pkt.randomize() with {addr == 8'h2;}) begin
				write(pkt.addr, pkt.data);
				$display("%0t: [testcase] Write - addr = %b, data = %b", $time, pkt.addr, pkt.data);
			end else begin
				$display("Randomization failed!");
			end

			if (pkt.randomize() with {addr == 8'h0; data[4:0] == {2'b00, 1'b1, 1'b0, 1'b0};}) begin
				write(pkt.addr, pkt.data);
				$display("%0t: [testcase] Write - addr = %b, data = %b", $time, pkt.addr, pkt.data);
			end else begin
				$display("Randomization failed!");
			end

			if (pkt.randomize() with {addr == 8'h0; data[4:0] == {2'b00, 1'b0, 1'b0, 1'b1};}) begin
				write(pkt.addr, pkt.data);
				$display("%0t: [testcase] Write - addr = %b, data = %b", $time, pkt.addr, pkt.data);
			end else begin
				$display("Randomization failed!");
			end

			T1 = $time;
			wait (dut_vif.interrupt);
			T2 = $time;

			env.scb.compare_timing(T2 - T1, env.scb.clk_div, (256 - env.scb.load_data) * 5ns);		
		end
	endtask

endclass
