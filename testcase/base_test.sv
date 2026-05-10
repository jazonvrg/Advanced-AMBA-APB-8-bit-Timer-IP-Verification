class base_test;

        packet pkt;
	environment env;

	virtual dut_if dut_vif;

	function new(virtual dut_if dut_vif);
		this.dut_vif = dut_vif;
		pkt = new();
	endfunction 

	function void build();
		env = new(dut_vif);
		env.build();
	endfunction

	task write(logic[7:0] addr, logic[7:0] data);
		pkt.addr = addr;
		pkt.data = data;
		pkt.transfer = packet::WRITE;
		env.stim.send_pkt(pkt);
		@(env.drv.xfer_done);	
	endtask

	task read(logic[7:0] addr, ref logic[7:0] data);
		pkt.addr = addr;
		pkt.transfer = packet::READ;
		env.stim.send_pkt(pkt);
		@(env.drv.xfer_done);	
		data = pkt.data;
	endtask

	virtual task run_scenario();
	endtask

	task reset();
		dut_vif.presetn <= 1'b0;
		dut_vif.paddr <= 8'h0;
		dut_vif.pwdata <= 8'h0;
		#10;
		dut_vif.presetn <= 1'b1;
		#1;
	endtask

	task run();
		build();
		fork
			env.run();
			run_scenario();
		join_any
	endtask	

endclass
