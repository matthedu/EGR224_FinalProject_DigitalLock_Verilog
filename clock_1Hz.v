/*******************
*File :         clock_1kHz 
*Assignment:    Lab 6
*Course:        EGR 224
*Instructor:    Professor Zuidema
*Author:        Dustin Matthews
*Date:          11/4/20
*Description:   Takes clock signal of BASYS3
*               and outputs a 1kHz clock signal
********************/
`timescale 1ns / 1ps

module clock_1kHz(clk_in, reset, clk_out);

input clk_in;
input reset;
output reg clk_out;
reg [16:0] count;
//For 1kHz, period = 100 000 000 / 1000 = 100 000
//DC = .5; therefore the clock must switch every 50 000 clock cycles

always @(posedge clk_in or posedge reset) //always @ similar to while(1)
begin
    if(reset)
    begin 
        clk_out <= 1'b0;
        count <=0;
    end
    else if (count == 50_000)
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
