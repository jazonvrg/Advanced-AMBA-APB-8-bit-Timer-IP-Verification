`timescale 1ns/1ps

module testbench; 

	import timer_pkg::*;
  	import test_pkg::*;
 
  	dut_if d_if();
  
  	timer_top u_dut(
    		.ker_clk(d_if.ker_clk),       
    		.pclk(d_if.pclk),       
    		.presetn(d_if.presetn),    
    		.psel(d_if.psel),       
    		.penable(d_if.penable),    
    		.pwrite(d_if.pwrite),     
    		.paddr(d_if.paddr),      
    		.pwdata(d_if.pwdata),     
    		.prdata(d_if.prdata),     
    		.pready(d_if.pready),     
    		.interrupt(d_if.interrupt));
	
  	initial begin
    		d_if.presetn = 0;
    		#100ns d_if.presetn = 1;
  	end

  	// 50 MHz
  	initial begin
    		d_if.pclk = 0;
    		forever begin 
      			#10ns;
      			d_if.pclk = ~d_if.pclk;
    		end
  	end
 
  	// 200 MHz
  	initial begin
    		d_if.ker_clk = 1;
    		forever begin 
      			#2.5ns;
      			d_if.ker_clk = ~d_if.ker_clk;
    		end
  	end

	base_test base;
	default_value_register_test default_value_register;
	tcr_test tcr;
	tdr_test tdr;
	tsr_test tsr;
	tie_test tie;
	rsv_test rsv;
	reset_test rst;
	no_divide_test no_divide;
	divide_2_test divide_2;
	divide_4_test divide_4;
	divide_8_test divide_8;
	timer_enable_test timer_enable;
	count_up_test count_up;
	count_down_test count_down;
	load_test load;
	overflow_test overflow;
	underflow_test underflow;
	count_up_interrupt_test count_up_interrupt;	
	count_down_interrupt_test count_down_interrupt;

  	initial begin
		base = new(d_if);
		default_value_register = new(d_if);
		tcr = new(d_if);
		tdr = new(d_if);
		tsr = new(d_if);
		tie = new(d_if);
		rsv = new(d_if);
		rst = new(d_if);
		no_divide = new(d_if);
		divide_2 = new(d_if);
		divide_4 = new(d_if);
		divide_8 = new(d_if);
		timer_enable = new(d_if);
		count_up = new(d_if);
		count_down = new(d_if);
		load = new(d_if);
		overflow = new(d_if);
		underflow = new(d_if);
		count_up_interrupt = new(d_if);
		count_down_interrupt = new(d_if);

		if ($test$plusargs("default_value_register_test")) begin
			base = default_value_register;
		end else if ($test$plusargs("tcr_test")) begin
			base = tcr;
		end else if ($test$plusargs("tdr_test")) begin
			base = tdr;
		end else if ($test$plusargs("tsr_test")) begin
			base = tsr;
		end else if ($test$plusargs("tie_test")) begin
			base = tie;
		end else if ($test$plusargs("rsv_test")) begin
			base = rsv;
		end else if ($test$plusargs("reset_test")) begin
			base = rst;
		end else if ($test$plusargs("no_divide_test")) begin
			base = no_divide;
		end else if ($test$plusargs("divide_2_test")) begin
			base = divide_2;
		end else if ($test$plusargs("divide_4_test")) begin
			base = divide_4;
		end else if ($test$plusargs("divide_8_test")) begin
			base = divide_8;
		end else if ($test$plusargs("timer_enable_test")) begin
			base = timer_enable;
		end else if ($test$plusargs("count_up_test")) begin
			base = count_up;
		end else if ($test$plusargs("count_down_test")) begin
			base = count_down;
		end else if ($test$plusargs("load_test")) begin
			base = load;
		end else if ($test$plusargs("overflow_test")) begin
			base = overflow;
		end else if ($test$plusargs("underflow_test")) begin
			base = underflow;
		end else if ($test$plusargs("count_up_interrupt_test")) begin
			base = count_up_interrupt;
		end else if ($test$plusargs("count_down_interrupt_test")) begin
			base = count_down_interrupt;
		end else begin
			base = default_value_register;
		end
		base.dut_vif = d_if;
		base.run();

		#1ms;
		$display("==========================================================================");
        	if (base.env.scb.err)
			$display("=============================== TEST FAILED ==============================");
 	       	else
			$display("=============================== TEST PASSED ==============================");
		$display("==========================================================================");

    		#1ms;
    		$display("[testbench] Time out....Seems your tb is hang!");
    		$finish;
  	end

endmodule
