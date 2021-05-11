/*******************
*File :         anode_counter 
*Assignment:    Lab 6
*Course:        EGR 224
*Instructor:    Professor Zuidema
*Author:        Dustin Matthews
*Date:          11/4/20
*Description:   Multiplexer that outputs a 4bit number based on the 2 bit select input 
*               to drive the individual seven-segment LEDs on the BASYS3
********************/
`timescale 1ns / 1ps
module anode_counter(sel, num_out);
input wire [1:0] sel;
output reg [3:0] num_out;

always @(sel)
begin
    case(sel)
        2'b00 : num_out <= 4'b0111;
        2'b01 : num_out <= 4'b1011;
        2'b10 : num_out <= 4'b1101;
        2'b11 : num_out <= 4'b1110;
    endcase
end        
endmodule
