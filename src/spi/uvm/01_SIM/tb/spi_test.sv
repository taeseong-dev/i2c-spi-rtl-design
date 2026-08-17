class spi_base_test extends uvm_test;
	`uvm_component_utils(spi_base_test)


	spi_env env;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		env = spi_env::type_id::create("env", this);
	endfunction

	virtual function void end_of_elaboration_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "===== UVM Hierarchy =====", UVM_MEDIUM)

		uvm_top.print_topology();
	endfunction

	virtual task run_phase(uvm_phase phase);

	endtask

endclass

class spi_rand_test extends spi_base_test;
	`uvm_component_utils(spi_rand_test)


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		spi_rand_seq seq;


		phase.raise_objection(this);

		seq = spi_rand_seq::type_id::create("seq");
		seq.num_loop = 1000;
		seq.start(env.cmd_agt.sqr);

		wait(env.scb.seq_num == seq.num_loop);

		phase.drop_objection(this);
	endtask

endclass
