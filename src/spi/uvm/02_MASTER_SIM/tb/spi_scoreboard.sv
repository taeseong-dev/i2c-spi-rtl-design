class spi_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(spi_scoreboard)


	uvm_tlm_analysis_fifo #(spi_exp_item) exp_fifo;
	uvm_tlm_analysis_fifo #(spi_act_item) act_fifo;

	int mode_pass_cnt = 0;
	int mode_fail_cnt = 0;

	int master_tx_pass_cnt = 0;
	int master_tx_fail_cnt = 0;

	int slave_tx_pass_cnt = 0;
	int slave_tx_fail_cnt = 0;

	int master_rx_pass_cnt = 0;
	int master_rx_fail_cnt = 0;

	int seq_num = 0;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		exp_fifo = new("exp_fifo", this);
		act_fifo = new("act_fifo", this);
	endfunction

	task run_phase(uvm_phase phase);
		spi_exp_item exp_item;
		spi_act_item act_item;


		forever begin
			exp_fifo.get(exp_item);
			act_fifo.get(act_item);

			compare_mode(exp_item, act_item);
			compare_master_tx(exp_item, act_item);
			compare_slave_tx(exp_item, act_item);
			compare_master_rx(exp_item, act_item);

			seq_num++;
		end
	endtask

	task compare_mode(spi_exp_item exp_item, spi_act_item act_item);
		if(({exp_item.cpol, exp_item.cpha}) !== ({act_item.cpol, act_item.cpha})) begin
			`uvm_error(get_type_name(), $sformatf("MODE MISMATCH, sequence=%0d, exp=%0d, act=%0d",
												 seq_num, {exp_item.cpol, exp_item.cpha},
												 {act_item.cpol, act_item.cpha}))
			mode_fail_cnt++;
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("MODE MATCH, sequence=%0d, mode=%0d",
												seq_num, {act_item.cpol, act_item.cpha}), UVM_MEDIUM)
			mode_pass_cnt++;
		end
	endtask

	task compare_master_tx(spi_exp_item exp_item, spi_act_item act_item);
		if(exp_item.tx_data !== act_item.bus_tx_data) begin
			`uvm_error(get_type_name(), $sformatf("MASTER TX MISMATCH, sequence=%0d, exp=0x%02h, bus=0x%02h",
												 seq_num, exp_item.tx_data, act_item.bus_tx_data))
			master_tx_fail_cnt++;
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("MASTER TX MATCH, sequence=%0d, exp=0x%02h, bus=0x%02h",
												seq_num, exp_item.tx_data, act_item.bus_tx_data), UVM_MEDIUM)
			master_tx_pass_cnt++;
		end
	endtask

	task compare_slave_tx(spi_exp_item exp_item, spi_act_item act_item);
		if(exp_item.miso_data !== act_item.bus_rx_data) begin
			`uvm_error(get_type_name(), $sformatf("SLAVE TX MISMATCH, sequence=%0d, exp=0x%02h, bus=0x%02h",
												 seq_num, exp_item.miso_data, act_item.bus_rx_data))
			slave_tx_fail_cnt++;
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("SLAVE TX MATCH, sequence=%0d, exp=0x%02h, bus=0x%02h",
												seq_num, exp_item.miso_data, act_item.bus_rx_data), UVM_MEDIUM)
			slave_tx_pass_cnt++;
		end
	endtask

	task compare_master_rx(spi_exp_item exp_item, spi_act_item act_item);
		if((exp_item.miso_data !== act_item.bus_rx_data) ||
		   (exp_item.miso_data !== act_item.master_rx_data)) begin
			`uvm_error(get_type_name(), $sformatf("MASTER RX MISMATCH, sequence=%0d, exp=0x%02h, bus=0x%02h, master=0x%02h",
												 seq_num, exp_item.miso_data,
												 act_item.bus_rx_data, act_item.master_rx_data))
			master_rx_fail_cnt++;
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("MASTER RX MATCH, sequence=%0d, exp=0x%02h, bus=0x%02h, master=0x%02h",
												seq_num, exp_item.miso_data,
												act_item.bus_rx_data, act_item.master_rx_data), UVM_MEDIUM)
			master_rx_pass_cnt++;
		end
	endtask

	function void report_phase(uvm_phase phase);
		bit overall_pass;


		super.report_phase(phase);

		overall_pass = (mode_fail_cnt      == 0) &&
					   (master_tx_fail_cnt == 0) &&
					   (slave_tx_fail_cnt  == 0) &&
					   (master_rx_fail_cnt == 0);

		`uvm_info(get_type_name(), "\n", UVM_LOW)
		`uvm_info(get_type_name(), "============ Scoreboard Summary ============", UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Test Total         : %4d", seq_num), UVM_LOW)
		`uvm_info(get_type_name(), "--------------------------------------------", UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Mode               : PASS=%4d  FAIL=%4d", mode_pass_cnt, mode_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Master TX          : PASS=%4d  FAIL=%4d", master_tx_pass_cnt, master_tx_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Slave TX           : PASS=%4d  FAIL=%4d", slave_tx_pass_cnt, slave_tx_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Master RX          : PASS=%4d  FAIL=%4d", master_rx_pass_cnt, master_rx_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), "--------------------------------------------", UVM_LOW)

		if(overall_pass) begin
			`uvm_info(get_type_name(), "Overall Result      : PASS", UVM_LOW)
		end
		else begin
			`uvm_info(get_type_name(), "Overall Result      : FAIL", UVM_LOW)
		end

		`uvm_info(get_type_name(), "============================================", UVM_LOW)
	endfunction

endclass
