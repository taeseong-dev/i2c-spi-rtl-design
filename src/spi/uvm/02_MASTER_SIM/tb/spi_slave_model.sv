class spi_slave_model extends uvm_component;
	`uvm_component_utils(spi_slave_model)


	virtual spi_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
			`uvm_fatal(get_type_name(), "spi interface is not found in config_db")
		end
	endfunction

	task run_phase(uvm_phase phase);
		logic [07:00] data;

		data = 8'h00;

		vif.miso <= 1'b0;

		wait(vif.rst == 0);

		forever begin
			@(negedge vif.cs_n);

			data = vif.miso_data;

			if(!vif.cpha) begin
				vif.miso <= data[7];

				for(int i=6; i>=0; i--) begin
					wait_shift_edge(vif.cpol, vif.cpha);

					vif.miso <= data[i];
				end
			end
			else begin
				for(int i=7; i>=0; i--) begin
					wait_shift_edge(vif.cpol, vif.cpha);

					vif.miso <= data[i];
				end
			end

			@(posedge vif.cs_n);

			vif.miso <= 1'b0;
		end
	endtask

	task wait_shift_edge(logic cpol, logic cpha);
		case({cpol, cpha})
			2'b00: begin
				@(negedge vif.sclk);
			end

			2'b01: begin
				@(posedge vif.sclk);
			end

			2'b10: begin
				@(posedge vif.sclk);
			end

			2'b11: begin
				@(negedge vif.sclk);
			end
		endcase
	endtask

endclass
