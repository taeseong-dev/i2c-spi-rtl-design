class i2c_base_test extends uvm_test;
	`uvm_component_utils(i2c_base_test)

	i2c_env env;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = i2c_env::type_id::create("env", this);
	endfunction

	virtual function void end_of_elaboration_phase(uvm_phase phase); //before run
		`uvm_info(get_type_name(), "===== UVM hierarchy ====", UVM_MEDIUM)
		uvm_top.print_topology();
	endfunction

	virtual task run_phase(uvm_phase phase);
		
	endtask

endclass

class i2c_write_test extends i2c_base_test;
	`uvm_component_utils(i2c_write_test)


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		i2c_write_seq seq;
		phase.raise_objection(this);
		seq = i2c_write_seq::type_id::create("seq");
		seq.num_loop = 10;
		seq.start(env.cmd_agt.sqr);
		phase.drop_objection(this);
	endtask

endclass

class i2c_read_test extends i2c_base_test;
	`uvm_component_utils(i2c_read_test)


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		i2c_read_seq seq;
		phase.raise_objection(this);
		seq = i2c_read_seq::type_id::create("seq");
		seq.num_loop = 2;
		seq.start(env.cmd_agt.sqr);
		phase.drop_objection(this);
	endtask

endclass

class i2c_write_read_test extends i2c_base_test;
	`uvm_component_utils(i2c_write_read_test)


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		i2c_write_read_seq seq;
		phase.raise_objection(this);
		seq = i2c_write_read_seq::type_id::create("seq");
		seq.num_loop = 100;
		seq.start(env.cmd_agt.sqr);
		phase.drop_objection(this);
	endtask

endclass

class i2c_rand_test extends i2c_base_test;
	`uvm_component_utils(i2c_rand_test)


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		i2c_rand_seq seq;
		phase.raise_objection(this);
		seq = i2c_rand_seq::type_id::create("seq");
		seq.num_loop = 1000;
		seq.start(env.cmd_agt.sqr);
		phase.drop_objection(this);
	endtask

endclass

