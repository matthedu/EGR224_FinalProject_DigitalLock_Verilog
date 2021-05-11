/*******************
*File :         Clock_Divider_1MHz 
*Assignment:    Lab 8
*Course:        EGR 224
*Instructor:    Professor Zuidema
*Author:        Dustin Matthews
*Date:          11/13/20
*Description:   takes clock signal of BASYS3
*               and outputs a 1MHz clock signal
********************/
`timescale 1ns / 1ps

module Clock_Divider_1MHz//(clk_in, reset, clk_out);
    (clk_in, clk_out);
input clk_in;
//input reset;
output reg clk_out;
reg [6:0] count;
//For 1MHz, period = 100 000 000 / 1 000 000 = 100
//DC = .5; therefore the counter must toggle every 50 clock cycles
always @(posedge clk_in)
begin
    if (count == 50)
    begin
        clk_out <= ~clk_out;
        count <= 0;
    end
    else
    begin 
        count <= (count + 1);
    end 
end     

endmodule
