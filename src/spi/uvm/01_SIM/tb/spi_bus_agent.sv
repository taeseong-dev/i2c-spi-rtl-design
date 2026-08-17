class spi_bus_agent extends uvm_agent;
	`uvm_component_utils(spi_bus_agent)


	spi_bus_monitor mon;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		mon = spi_bus_monitor::type_id::create("mon", this);
	endfunction

endclass
