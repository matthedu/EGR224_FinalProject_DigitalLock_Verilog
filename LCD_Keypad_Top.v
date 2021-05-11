/*******************
*File :         LCD_Keypad_Top 
*Assignment:    Final Project
*Course:        EGR 224
*Instructor:    Professor Zuidema
*Author:        Dustin Matthews
*Date:          12/11/20
*Description:   Manages all input and output of LCD and Keypad 
********************/
`timescale 1ns / 1ps

module 
LCD_Keypad_Top  (clk, rst, data, rs, rw, e, 
                row, col, anode, seven_seg, PIN, key_flag);
input wire clk,
           rst;
input [3:0] row;
output [3:0] col;
output wire [7:0] data;
output wire [3:0] anode;
output wire [6:0] seven_seg; 
output wire [1:0] PIN;      //display current pin index on LEDs
output wire rs, 
            rw, 
            e;
output wire key_flag;       //indicate key pressed on LED
           
wire rst_deb,
     clk_div, 
     clk_1K;
wire [7:0] raw_key,
           checked_key;
wire [1:0] select;

///////////////////////
//INSTANTIATE MODULES//
///////////////////////
Clock_Divider_1MHz CD1(.clk_in(clk),  .clk_out(clk_div));

rst_debounce DB2 (.clk(clk_div), .reset(rst), .rst_db(rst_deb));

LCD_Upper_FSM LCD1 (.clk_in(clk_div), .reset(rst_deb), .keypad_flag(key_flag), 
                    .keypad_in(checked_key), .data_out(data), .rs_out(rs),
                     .rw_out(rw), .e_out(e), .PIN_index(PIN));
                
                
keypad_decoder KP1 (.clk(clk_div), .reset(rst_deb), .col(col), .row(row), 
                    .decode(raw_key)); 

key_flag_debounce DB1  (.clk(clk_div), .reset(rst_deb), .key_in(raw_key), .flag_out(key_flag), .key_out(checked_key));  
 

clock_1kHz CD2 (.clk_in(clk), .reset(rst_deb), .clk_out(clk_1K));  

counter_2bit C2B(.reset(rst_deb), .clk_in(clk_1K), .count(select)); 
 
anode_counter AC (.sel(select), .num_out(anode)); 

sev_seg S7 (.num_in(raw_key), .seg_out(seven_seg));   


endmodule
