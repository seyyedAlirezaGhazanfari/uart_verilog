`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:36:44 12/14/2021
// Design Name:   uart
// Module Name:   F:/university/00-01/DSD_Lab/Az_1/final_Az_7/uart_test.v
// Project Name:  final_Az_7
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: uart
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module uart_test;

	// Inputs
	reg [6:0] data;
	reg save;
	reg clk;

	// Outputs
	wire [6:0] data_out;
	wire ready;
	wire error;

	// Instantiate the Unit Under Test (UUT)
	uart uut (
		.data(data), 
		.save(save), 
		.clk(clk), 
		.data_out(data_out), 
		.ready(ready), 
		.error(error)
	);

	initial begin
		// Initialize Inputs
		data = 0;
		save = 0;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		save = 1;
		data = 7'b1100110;
		#20;
		save = 0;
		#100;

	end
	
	always clk = #10 ~clk;
      
endmodule

