class i2c_env extends uvm_env;
	`uvm_component_utils(i2c_env)

	i2c_cmd_agent cmd_agt;
	i2c_bus_agent bus_agt;

	i2c_scoreboard scb;
	i2c_coverage   cov;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		cmd_agt = i2c_cmd_agent::type_id::create("cmd_agt", this);
		bus_agt = i2c_bus_agent::type_id::create("bus_agt", this);
		scb     = i2c_scoreboard::type_id::create("scb", this);
		cov     = i2c_coverage::type_id::create("cov", this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		cmd_agt.mon.ap.connect(scb.exp_fifo.analysis_export);
		bus_agt.mon.ap.connect(scb.act_fifo.analysis_export);

		bus_agt.mon.ap.connect(cov.analysis_export);
	endfunction

endclass
