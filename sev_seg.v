/*******************
*File :         sev_seg 
*Assignment:    Final Project
*Course:        EGR 224
*Instructor:    Professor Zuidema
*Author:        Dustin Matthews
*Date:          12/11/20
*Description:   drives the segments of the seven segment LEDs based on the input given
*               Shows the last key pressed on the keypad
********************/
`timescale 1ns / 1ps

module sev_seg(num_in, seg_out);

input wire [7:0] num_in;
output reg [6:0] seg_out = 7'b1111111;

always @(num_in)
begin 
    
    case(num_in)
        "0" : seg_out <= 7'b0000001;//0
        "1" : seg_out <= 7'b1001111;//1
        "2" : seg_out <= 7'b0010010;//2
        "3" : seg_out <= 7'b0000110;//3
        "4" : seg_out <= 7'b1001100;//4
        "5" : seg_out <= 7'b0100100;//5
        "6" : seg_out <= 7'b0100000;//6
        "7" : seg_out <= 7'b0001111;//7
        "8" : seg_out <= 7'b0000000;//8
        "9" : seg_out <= 7'b0001100;//9
        "A" : seg_out <= 7'b0001000;//a
        "B" : seg_out <= 7'b1100000;//b
        "C" : seg_out <= 7'b0110001;//c
        "D" : seg_out <= 7'b1000010;//d
        "E" : seg_out <= 7'b0110000;//e
        "F" : seg_out <= 7'b0111000;//f
        "?" : seg_out <= 7'b1100010;
        default : seg_out <= 7'b1111111;

    endcase
end
endmodule
