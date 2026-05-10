class driver;

	packet pkt;

	virtual dut_if dut_vif;
	event xfer_done;

	mailbox #(packet) s2d_mb;

	function new(virtual dut_if dut_vif, mailbox #(packet) s2d_mb);
		this.dut_vif = dut_vif;
		this.s2d_mb = s2d_mb;
	endfunction 

	task run();
		while (1) begin
			pkt = new();	
			s2d_mb.get(pkt);
      			$display("%0t: [driver] Get packet from stimulus", $time);

			// SETUP PHASE
			@(posedge dut_vif.pclk);
			dut_vif.psel <= 1'b1;
			dut_vif.penable <= 1'b0;
			dut_vif.pwrite <= pkt.transfer;
			dut_vif.paddr <= pkt.addr;
			if (pkt.transfer == packet::WRITE) begin
				dut_vif.pwdata <= pkt.data;
			end
			// ACCESS PHASE
			@(posedge dut_vif.pclk);
			if (pkt.transfer == packet::READ) begin
				pkt.data = dut_vif.prdata;
			end
			dut_vif.penable <= 1'b1;
			// IDLE
			@(posedge dut_vif.pclk);
			dut_vif.psel <= 1'b0;
			dut_vif.penable <= 1'b0;

			-> xfer_done;
		end
	endtask

endclass
