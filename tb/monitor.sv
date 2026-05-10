class monitor;

	packet pkt;

	virtual dut_if dut_vif;
	
	mailbox #(packet) m2s_mb;

	function new(virtual dut_if dut_vif, mailbox #(packet) m2s_mb);
		this.dut_vif = dut_vif;
		this.m2s_mb = m2s_mb;
	endfunction 

	task run();
		while (1) begin
			pkt = new();
			@(posedge dut_vif.pclk);
			if (dut_vif.psel && dut_vif.penable) begin
				pkt.addr = dut_vif.paddr;
				if (!dut_vif.pwrite) begin
					pkt.data = dut_vif.prdata;
					pkt.transfer = packet::READ;
				end else begin
					pkt.data = dut_vif.pwdata;
					pkt.transfer = packet::WRITE;
				end
      				$display("%0t: [monitor] Captured APB transaction", $time);
				m2s_mb.put(pkt);
			end	
		end
	endtask

endclass
