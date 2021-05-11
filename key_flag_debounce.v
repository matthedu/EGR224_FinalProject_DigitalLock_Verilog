/*******************
*File :         key_flag_debounce 
*Assignment:    Final Project
*Course:        EGR 224
*Instructor:    Professor Zuidema
*Author:        Dustin Matthews
*Date:          12/11/20
*Description:   Short debounce before key flag is sent to LCD Control Module 
********************/
`timescale 1ns / 1ps

module 
key_flag_debounce(clk, reset, key_in, flag_out, key_out);

input clk, reset;
input wire [7:0] key_in;
output wire [7:0] key_out;
output reg flag_out = 0;
reg [7:0] buffer_key, buffer_key1;

always @ (posedge clk) begin
    buffer_key <= key_in;
    buffer_key1 <= buffer_key;
end
assign key_out = buffer_key1;

always @ (posedge clk) begin
    if ((key_out == "?") || (reset == 1))
        flag_out <= 0;
    else 
        flag_out <= 1;
end            
    
/*
reg [12:0] db_count = 0;
reg [12:0] max_count = 12'h7FF;                //max count of debounce

parameter   idle = 2'b00,
            count = 2'b01,
            check = 2'b10;
            
reg [1:0] deb_state = idle;
wire key_pressed = (key_in != "?");   //high when state of key unchanged
 */
/*** DEBOUNCE ***/
/*
always @ (posedge clk) begin
    if (reset) begin 
        deb_state <= idle;
        key_out <= key_out;
        flag_out <= 0;
    end
    else begin
        case (deb_state)
            idle : begin
                key_out <= key_out;
                flag_out <= flag_out;              
                db_count <= 0;
                if (key_pressed) begin
                    deb_state <= count;
                end    
                else
                    deb_state <= idle;                   
            end
            count : begin   
                key_out <= key_out;
                flag_out <= flag_out;           
                db_count <= count + 1; 
                    if (db_count == max_count)
                        deb_state <= check;
                    else deb_state <= count;       
            end
            check : begin
                if (key_pressed) begin
                    key_out <= key_in;
                    flag_out <= 1;
                end     
                else begin
                    key_out <= key_out;
                    flag_out <= 0;
                end    
                deb_state <= idle;     
            end
            default : begin
                deb_state <= idle;  
                key_out <= key_out; 
                flag_out <= 0; 
            end
        endcase
    end        
end          
*/
endmodule
