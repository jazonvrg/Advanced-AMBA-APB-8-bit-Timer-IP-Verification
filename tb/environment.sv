class environment;

	stimulus stim;
	driver drv;
	monitor mnt;
	scoreboard scb;

	mailbox #(packet) s2d_mb;
	mailbox #(packet) m2s_mb;

	virtual dut_if dut_vif;

	function new(virtual dut_if dut_vif);
		this.dut_vif = dut_vif;
	endfunction

	function void build();
		$display("%0t: [environment] build", $time);
		s2d_mb = new();
		m2s_mb = new();
		stim = new(s2d_mb);
		drv = new(dut_vif, s2d_mb);
		mnt = new(dut_vif, m2s_mb);
		scb = new(dut_vif, m2s_mb);
	endfunction

	task run();
		fork
			stim.run();
			drv.run();
			mnt.run();
			scb.run();
		join
	endtask

endclass
