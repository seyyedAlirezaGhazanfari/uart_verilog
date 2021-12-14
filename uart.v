`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:42:56 12/13/2021 
// Design Name: 
// Module Name:    uart 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uart(
	input [6:0] data,
	input save,
	input clk,
	output [6:0] data_out,
	output ready,
	output error
);
wire transfered_data;
transmitter tr (.save(save), .data(data), .clk(clk), .serial_data(transfered_data));
reciever re(.start(save), .serial_data_in(transfered_data), .data_out(data_out), .ready(ready), .error(error), .clk(clk));
endmodule



module transmitter(
		input save,
		input [6:0] data,
		input clk,
		output reg serial_data
    );
localparam SAVE=0, START =1, DATA =2, STOP =3;

reg [1:0] current_state, next_state;

reg [7:0] saved_data;
reg [2:0] count;

always @(posedge clk) begin
	if (save) begin
		count <= 3'b000;
		saved_data <= {data, ^data};
		current_state <= START;
		serial_data <= 0;
	end
	else begin
		current_state <= next_state;
		serial_data <= 1'b0;
		case (current_state)
			START: 
				serial_data <= 1'b1; // sends start bit
			DATA: begin
				serial_data <= saved_data[count];
				count <= count + 1'b1;
			end
			STOP:
				serial_data <= 1'b1; // sends stop bit
			default: begin
				saved_data <= 0;
				current_state <= 0;
				serial_data <= 0;
				count <= 3'b000;
			end
		endcase
	end
end

always @(*) begin
	next_state = current_state;
	case(current_state)
		START:
			next_state = DATA;
		DATA:
			if(count == 3'b111) next_state = STOP;
	endcase
end
endmodule




module reciever (
	input start,
	input serial_data_in,
	input clk,
	output reg [6:0] data_out,
	output reg ready,
	output reg error
);

localparam START=0, PARITY = 1, DATA=2, STOP=3;

reg [2:0] count;
reg [6:0] saved_data;

reg parity;
reg [1:0] current_state, next_state;

always @(posedge clk) begin
	if (start) begin
		current_state <= START;
		error <= 1'b0;
		data_out <= 0;
		saved_data <= 0;
		count <= 0;
	end
	else begin
		current_state <= next_state;
		error <= 1'b0;
		data_out <= 0;
		ready <=1'b0;
		case (current_state) 
			PARITY: begin
				parity <= serial_data_in;
			end
			DATA: begin
				saved_data[count] <= serial_data_in;
				count <= count + 1'b1;
			end
			STOP: begin
				ready <= 1'b1;
				data_out <= saved_data;
				if (parity != ^saved_data)
					error <= 1;
			end
			default begin
				parity <= 0;
				saved_data <= 0;
			end
		endcase
	end
end


always @(*) begin
	next_state = current_state;
	case (current_state) 
		START:
			if (serial_data_in) 
				next_state = PARITY;
		PARITY:
			next_state = DATA;
		DATA:
			if (count == 3'b111)
				next_state = STOP;
		STOP:
			next_state = STOP;
	endcase
end

endmodule
