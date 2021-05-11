/*******************
*File :         rst_debounce 
*Assignment:    Final Project
*Course:        EGR 224
*Instructor:    Professor Zuidema
*Author:        Dustin Matthews
*Date:          12/11/20
*Description:   Debounce the reset button 
********************/
`timescale 1ns / 1ps

module 
rst_debounce(clk, reset, rst_db);

input clk, reset;
output rst_db;
reg wait1, wait2, wait3, wait4;

always @ (posedge clk) begin
        wait1 <= reset;
        wait2 <= wait1;
        wait3 <= wait2;
        wait4 <= wait3;
end
    
assign rst_db = (wait1 & wait2 & wait3 & wait4);

endmodule
