/*******************
*File :         2Bit Counter 
*Assignment:    Lab 6
*Course:        EGR 224
*Instructor:    Professor Zuidema
*Author:        Dustin Matthews
*Date:          11/4/20
*Description:   Module counts 00 01 10 11 00... if reset (BTNC on BASYS3) is pressed, 
*               resets count to 0
*               Used to cycle the 7seg Anode Mux
********************/
`timescale 1ns / 1ps
module counter_2bit(reset, clk_in, count);
input reset, clk_in;
output reg [1:0] count;

always @(posedge clk_in)
    begin 
    if (reset) count <= 2'b00;
    else count <= (count + 1); 
    end
endmodule
