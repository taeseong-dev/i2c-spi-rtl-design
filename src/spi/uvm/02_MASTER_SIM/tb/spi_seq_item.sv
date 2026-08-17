class spi_seq_item extends uvm_sequence_item;


	rand logic		 cpol;
	rand logic		 cpha;
	rand logic [07:00] tx_data;
	rand logic [07:00] miso_data;

	`uvm_object_utils_begin(spi_seq_item)
		`uvm_field_int(cpol,      UVM_ALL_ON)
		`uvm_field_int(cpha,      UVM_ALL_ON)
		`uvm_field_int(tx_data,   UVM_ALL_ON)
		`uvm_field_int(miso_data, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "spi_seq_item");
		super.new(name);
	endfunction

	function string convert2string();
		string str;

		str = $sformatf("mode=%0d, cpol=%0d, cpha=%0d, tx_data=0x%02h, miso_data=0x%02h",
						{cpol, cpha}, cpol, cpha, tx_data, miso_data);

		return str;
	endfunction

endclass


class spi_exp_item extends uvm_sequence_item;


	logic		 cpol;
	logic		 cpha;
	logic [07:00] tx_data;
	logic [07:00] miso_data;

	`uvm_object_utils_begin(spi_exp_item)
		`uvm_field_int(cpol,      UVM_ALL_ON)
		`uvm_field_int(cpha,      UVM_ALL_ON)
		`uvm_field_int(tx_data,   UVM_ALL_ON)
		`uvm_field_int(miso_data, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "spi_exp_item");
		super.new(name);
	endfunction

	function string convert2string();
		string str;

		str = $sformatf("mode=%0d, cpol=%0d, cpha=%0d, tx_data=0x%02h, miso_data=0x%02h",
						{cpol, cpha}, cpol, cpha, tx_data, miso_data);

		return str;
	endfunction

endclass


class spi_act_item extends uvm_sequence_item;


	logic		 cpol;
	logic		 cpha;

	logic [07:00] bus_tx_data;
	logic [07:00] bus_rx_data;

	logic [07:00] master_rx_data;

	`uvm_object_utils_begin(spi_act_item)
		`uvm_field_int(cpol,           UVM_ALL_ON)
		`uvm_field_int(cpha,           UVM_ALL_ON)
		`uvm_field_int(bus_tx_data,    UVM_ALL_ON)
		`uvm_field_int(bus_rx_data,    UVM_ALL_ON)
		`uvm_field_int(master_rx_data, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "spi_act_item");
		super.new(name);
	endfunction

	function string convert2string();
		string str;

		str = $sformatf("mode=%0d, cpol=%0d, cpha=%0d, bus_tx=0x%02h, bus_rx=0x%02h, master_rx=0x%02h",
						{cpol, cpha}, cpol, cpha, bus_tx_data, bus_rx_data, master_rx_data);

		return str;
	endfunction

endclass
