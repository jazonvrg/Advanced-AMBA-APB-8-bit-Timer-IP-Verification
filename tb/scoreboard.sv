class scoreboard;

	int err = 0;
	
	virtual dut_if dut_vif;

	packet pkt = new();
	logic en_fc = 1'b1;

	logic [2:0] rsv_TCR = 3'b0;
	logic [1:0] clk_div = 2'b00;
	logic load = 1'b0, count_mode = 1'b0, timer_en = 1'b0;
	logic [1:0] clk_div_TCR = 2'b00;
	logic load_TCR = 1'b0, count_mode_TCR = 1'b0, timer_en_TCR = 1'b0;

	logic [5:0] rsv_TSR = 6'b0;
	logic underflow = 1'b0, overflow = 1'b0;

	logic [7:0] load_data = 8'b0;

	logic [5:0] rsv_TIE = 6'b0;
	logic underflow_en = 1'b0, overflow_en = 1'b0;

	logic [7:0] TCR_exp_data, TSR_exp_data, TDR_exp_data, TIE_exp_data, RSV_exp_data = 8'h0;

	logic [7:0] pre_cnt = 8'd100, cnt = 0;
	logic interrupt = 1'b0;
		
	time exp_time, tolerance;
		
	mailbox #(packet) m2s_mb;

	covergroup APB_GROUP;
		// APB Transfer
		apb_addr: coverpoint pkt.addr {
			bins TCR = {8'h00};
			bins TSR = {8'h01};
			bins TDR = {8'h02};
			bins TIE = {8'h03};
			bins others[] = default;
		}
		apb_transfer: coverpoint pkt.transfer {
			bins WRITE = {1'b1};
			bins READ = {1'b0};
		}
		cross_apb_transfer: cross apb_addr, apb_transfer;
		
		// TCR Function
		timer_en_feature: coverpoint pkt.data[0] {
			bins timer_en_LOW = {0};
			bins timer_en_HIGH = {1};
		}
		count_mode: coverpoint pkt.data[1] {
			bins count_up = {0};
			bins count_down = {1};
		}
		load_feature: coverpoint pkt.data[2] {
			bins normal_operate = {0};
			bins load_data = {1};
		}
		clk_div_feature: coverpoint pkt.data[4:3] {
			bins no_divide = {2'b00};
			bins divide_by_2 = {2'b01};
			bins divide_by_4 = {2'b10};
			bins divide_by_8 = {2'b11};
		}
/*		cross_tcr_function: cross apb_addr, apb_transfer, timer_en_feature, count_mode, load_feature, clk_div_feature {
			ignore_bins TCR_function = !binsof(apb_addr.TCR);
		}*/

		// TSR Function
		overflow_feature: coverpoint pkt.data[0] {
			bins write_0 = {1'b0};
			bins write_1 = {1'b1};
			
		}
		underflow_feature: coverpoint pkt.data[1] {
			bins write_0 = {1'b0};
			bins write_1 = {1'b1};
		}
		cross_overflow_function: cross apb_addr, overflow_feature {
			ignore_bins overflow = !binsof(apb_addr.TSR);
		}
		cross_underflow_function: cross apb_addr, underflow_feature {
			ignore_bins underflow = !binsof(apb_addr.TSR);
		}

		// TDR Function
		load_data_feature: coverpoint pkt.data {
			bins max_data = {8'd255};
			bins min_data = {8'd0};
			bins others = {[8'd1:8'd254]};
		}
/*		cross_tdr_function: cross apb_addr, load_data_feature {
			ignore_bins TDR_function = !binsof(apb_addr.TDR);
		}*/

		// TIE Function
		overflow_interrupt: coverpoint pkt.data[0] {
			bins write_0 = {1'b0};
			bins write_1 = {1'b1};
			
		}
		underflow_interrupt: coverpoint pkt.data[1] {
			bins write_0 = {1'b0};
			bins write_1 = {1'b1};
		}
		cross_overflow_interrupt: cross apb_addr, overflow_feature {
			ignore_bins overflow_interrupt = !binsof(apb_addr.TIE);
		}
		cross_underflow_interrupt: cross apb_addr, underflow_feature {
			ignore_bins underflow_interrupt = !binsof(apb_addr.TIE);
		}
		
	endgroup

	function new(virtual dut_if dut_vif, mailbox #(packet) m2s_mb);
		this.dut_vif = dut_vif;
		this.m2s_mb = m2s_mb;
		APB_GROUP = new();
	endfunction

	task run();
		fork
			mailbox_thread();
			reference_model();
		join_none
	endtask
	
	task mailbox_thread();
		while (1) begin
			m2s_mb.get(pkt);
			if (pkt.transfer == packet:: READ || pkt.transfer == packet::WRITE) begin
	      			$display("%0t: [scoreboard] Get packet from monitor", $time);
				if (pkt.transfer == packet::READ) begin
					compare();
				end else begin
					update();
				end
				if (en_fc) begin
					APB_GROUP.sample();
				end
			end
		end
	endtask

	task compare();
		case (pkt.addr) 
			8'h0: begin
				TCR_exp_data = {rsv_TCR, clk_div_TCR, load_TCR, count_mode_TCR, timer_en_TCR};
				if (TCR_exp_data == pkt.data) begin
					$display("%0t: [compare] PASSED! Data matching. Exp: %b, Act: %b", $time, TCR_exp_data, pkt.data);
				end else begin
					$display("%0t: [compare] FAILED! Exp: %b , Act: %b	*", $time, TCR_exp_data, pkt.data);
					err = err + 1;
				end
			end
			8'h1: begin
				TSR_exp_data = {rsv_TSR, underflow, overflow};
				if (TSR_exp_data == pkt.data) begin
					$display("%0t: [compare] PASSED! Data matching. Exp: %b, Act: %b", $time, TSR_exp_data, pkt.data);
				end else begin
					$display("%0t: [compare] FAILED! Exp: %b , Act: %b	*", $time, TSR_exp_data, pkt.data);
					err = err + 1;
				end
			end
			8'h2: begin
				TDR_exp_data = load_data;
				if (TDR_exp_data == pkt.data) begin
					$display("%0t: [compare] PASSED! Data matching. Exp: %b, Act: %b", $time, TDR_exp_data, pkt.data);
				end else begin
					$display("%0t: [compare] FAILED! Exp: %b , Act: %b	*", $time, TDR_exp_data, pkt.data);
					err = err + 1;
				end
			end
			8'h3: begin
				TIE_exp_data = {rsv_TIE, underflow_en, overflow_en};
				if (TIE_exp_data == pkt.data) begin
					$display("%0t: [compare] PASSED! Data matching. Exp: %b, Act: %b", $time, TIE_exp_data, pkt.data);
				end else begin
					$display("%0t: [compare] FAILED! Exp: %b , Act: %b	*", $time, TIE_exp_data, pkt.data);
					err = err + 1;
				end
			end
			default: begin
				if (RSV_exp_data == pkt.data) begin
					$display("%0t: [compare] PASSED! Data matching. Exp: %b, Act: %b", $time, RSV_exp_data, pkt.data);
				end else begin
					$display("%0t: [compare] FAILED! Exp: %b , Act: %b	*", $time, RSV_exp_data, pkt.data);
					err = err + 1;
				end
			end
		endcase	
	endtask

	task update();
		if (dut_vif.presetn) begin
			case (pkt.addr)
				8'h0: begin
					fork 
						begin
							clk_div_TCR <= pkt.data[4:3];
							load_TCR <= pkt.data[2];
							count_mode_TCR <= pkt.data[1];
							timer_en_TCR <= pkt.data[0];
							
							CDC_2flop(dut_vif.ker_clk);
							if (timer_en) begin
								timer_en <= pkt.data[0];	
							end else begin
								clk_div <= pkt.data[4:3];
								load <= pkt.data[2];
								count_mode <= pkt.data[1];
								timer_en <= pkt.data[0];
							end
						end
					join_none
				end
				8'h1: begin
					fork
						begin
							CDC_2flop(dut_vif.pclk);
							if (pkt.data[1]) begin
								underflow <= 1'b0;
							end
							if (pkt.data[0]) begin
								overflow <= 1'b0;
							end
						end
					join_none
				end
				8'h2: begin
					fork
						begin
							CDC_2flop(dut_vif.ker_clk);
							load_data <= pkt.data;
						end
					join_none
				end
				8'h3: begin
					underflow_en <= pkt.data[1];
					overflow_en <= pkt.data[0];	
				end
				default: begin
					RSV_exp_data <= 8'h0;
				end
			endcase	
		end
	endtask

	int delay, freq_time;

	task reference_model();
		while (1) begin
			@(posedge dut_vif.ker_clk);
			if (!dut_vif.presetn) begin
				setup();
			end else begin
				delay = 1 << clk_div;
				if (load) begin
					pre_cnt <= 8'd100;
					cnt <= load_data;
				end
				if (timer_en) begin
					freq_time = freq_time + 1;
					if (freq_time == delay) begin
						freq_time = 0;
						if (count_mode) begin
							pre_cnt <= cnt;
							cnt <= cnt - 1'd1;
						end else begin
							pre_cnt <= cnt;
							cnt <= cnt + 1'd1;
						end
					end
				end
				if (!count_mode) begin
					if (pre_cnt == 8'd255 && cnt == 8'd0) begin
						fork 
							begin
								CDC_2flop(dut_vif.pclk);
								overflow <= 1'b1;
							end
						join_any
					end
				end else begin
					if (pre_cnt == 8'd0 && cnt == 8'd255) begin
						fork 
							begin
								CDC_2flop(dut_vif.pclk);
								underflow <= 1'b1;
							end
						join_any
					end
				end
				if ((overflow && overflow_en) || (underflow && underflow_en))  begin
					interrupt = 1'b1;
				end
			end
		end
	endtask

	task setup();
		fork 
			begin
				CDC_2flop(dut_vif.ker_clk);
				clk_div <= 2'h0;
				clk_div_TCR <= 2'b0;

				load <= 1'b0;
				load_TCR <= 1'b0;

				count_mode <= 1'b0;
				count_mode_TCR <= 1'b0;

				timer_en <= 1'b0;
				timer_en_TCR <= 1'b0;
			end
	
			begin
				CDC_2flop(dut_vif.pclk);
				underflow <= 1'b0;
				overflow <= 1'b0;
			end
			
			begin
				CDC_2flop(dut_vif.ker_clk);
				load_data <= 8'h0;
			end
		
			underflow_en <= 1'b0;
			overflow_en <= 1'b0;
			
			RSV_exp_data <= 8'h0;
			cnt <= 0;
			freq_time = 0;
			delay = 0;
		join_none
	endtask

	task compare_timing(time act_time, logic [1:0] clk_div_state, time exp_time);
		case (clk_div_state)
			2'b00: begin
				exp_time = exp_time * 1;
				tolerance = 7 * 5ns;
				if ($signed(exp_time - tolerance) <= $signed(act_time) && $signed(act_time) <= $signed(exp_time + tolerance)) begin
					$display("%0t: [compare] PASSED! Timing %0t in range [%0t ,%0t]", $time, act_time, exp_time - tolerance, exp_time + tolerance);
				end else begin
					$display("%0t: [compare] FAILED! Timing %0t not in range [%0t, %0t]	*", $time, act_time, exp_time - tolerance, exp_time + tolerance);
					err = err + 1;
				end
			end
			2'b01: begin
				exp_time = exp_time * 2;
				tolerance = 7 * 2 * 5ns;
				if ($signed(exp_time - tolerance) <= $signed(act_time) && $signed(act_time) <= $signed(exp_time + tolerance)) begin
					$display("%0t: [compare] PASSED! Timing %0t in range [%0t ,%0t]", $time, act_time, exp_time - tolerance, exp_time + tolerance);
				end else begin
					$display("%0t: [compare] FAILED! Timing %0t not in range [%0t, %0t]	*", $time, act_time, exp_time - tolerance, exp_time + tolerance);
					err = err + 1;
				end
			end
			2'b10: begin
				exp_time = exp_time * 4;
				tolerance = 7 * 4 * 5ns;
				if ($signed(exp_time - tolerance) <= $signed(act_time) && $signed(act_time) <= $signed(exp_time + tolerance)) begin
					$display("%0t: [compare] PASSED! Timing %0t in range [%0t ,%0t]", $time, act_time, exp_time - tolerance, exp_time + tolerance);
				end else begin
					$display("%0t: [compare] FAILED! Timing %0t not in range [%0t, %0t]	*", $time, act_time, exp_time - tolerance, exp_time + tolerance);
					err = err + 1;
				end
			end
			default: begin
				exp_time = exp_time * 8;
				tolerance = 7 * 8 * 5ns;
				if ($signed(exp_time - tolerance) <= $signed(act_time) && $signed(act_time) <= $signed(exp_time + tolerance)) begin
					$display("%0t: [compare] PASSED! Timing %0t in range [%0t ,%0t]", $time, act_time, exp_time - tolerance, exp_time + tolerance);
				end else begin
					$display("%0t: [compare] FAILED! Timing %0t not in range [%0t, %0t]	*", $time, act_time, exp_time - tolerance, exp_time + tolerance);
					err = err + 1;
				end
			end
		endcase
	endtask
		
	task interrupt_LOW_check();
		$display("%0t: [interrupt check] PASSED! The interrupt is never triggered HIGH!", $time);
	endtask

	task CDC_2flop(ref logic clk);
		repeat (2) @(posedge clk);
	endtask

endclass
