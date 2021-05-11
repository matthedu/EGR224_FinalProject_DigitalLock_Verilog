/*******************
*File :         keypad_decoder 
*Assignment:    Final Project
*Course:        EGR 224
*Instructor:    Professor Zuidema
*Author:        Dustin Matthews
*Date:          12/11/20
*Description:   Reads the 4x4 matrix keypad 
********************/
`timescale 1ns / 1ps

module 
keypad_decoder (clk, reset, row, col, decode);

//REGISTERS AND WIRES
inout [3:0] row, col;
output reg [7:0] decode;       

input wire  clk, 
            reset;
wire [3:0]  state,
            sub; 
wire delay_flag;               
reg [20:0] count; 

reg [3:0] nextState,
          ColType;
wire[4:0] key_index;
reg [1:0] col_tracker;              //2bit number to track which column is active
wire [7:0] keypad [16:0];

parameter   stateShift = 4'b1000,
            stateWait = 4'b0100, 
            stateRead = 4'b0010, 
            stateInit = 4'b0001;
            
// Next state logic            
assign state = nextState;

//Manage high impedance columns
assign col[3] = ColType[3]?1'bZ:1'b0;
assign col[2] = ColType[2]?1'bZ:1'b0;
assign col[1] = ColType[1]?1'bZ:1'b0;
assign col[0] = ColType[0]?1'bZ:1'b0;

/*** Variable used to determine key index ****/
assign sub = (row == 4'b1110) ? 2 :
             (row == 4'b1101) ? 5 :
             (row == 4'b1011) ? 7 :
             (row == 4'b0111) ? 7 :
                                0 ;                                                
/**** KEYPAD ARRAY ****/ 
assign keypad[0]    = "1";
assign keypad[1]    = "2";
assign keypad[2]    = "3";
assign keypad[3]    = "A";
assign keypad[4]    = "4";
assign keypad[5]    = "5";
assign keypad[6]    = "6";
assign keypad[7]    = "B";
assign keypad[8]    = "7";
assign keypad[9]    = "8";
assign keypad[10]   = "9";
assign keypad[11]   = "C";
assign keypad[12]   = "0";
assign keypad[13]   = "F";
assign keypad[14]   = "E";
assign keypad[15]   = "D";
assign keypad[16]   = "?";

/**** DELAY FLAG ****/
//1MHz clock input, 1000 cycles = 1ms
assign delay_flag = ((state == stateWait) && (count == 100)) ||             
                    ((state == stateRead) && (count == 900)) ? 1'b1: 1'b0;  
/************ DELAY COUNTER *************/
//Increment counter when setting columns//
//********and when reading rows*********//                    
always @ (posedge clk) begin
    if ((delay_flag == 1) || (reset))
        count <= 0;       
    //increment counter only when in stateWait or stateRead    
    else if  ((state == stateWait) || (state == stateRead))
        count <= (count + 1);
    else count <= 0;        
end      

/**** FINITE STATE MACHINE ****/
//Cycle the columns to be read//
always @ (posedge clk) begin
    if (reset) 
        nextState <= stateInit;
    else begin 
        case (state) 
            stateInit : begin
                decode <= decode;
                ColType <= 4'b0111;                             //initialize column value
                col_tracker <= 2'b00;                           //initialize tracker value
                nextState <= stateWait;
            end
            stateWait : begin               
                ColType <= ColType;                             //maintain column value while in state 
                col_tracker <= col_tracker;
                decode <= decode;
                if (delay_flag == 1'b1)                         //allow new column value to 'settle'     
                    nextState <= stateRead;
                else nextState <= stateWait;
            end
            stateRead : begin
                ColType <= ColType;
                col_tracker <= col_tracker;
                if (row != 4'b1111)
                    decode <= keypad[key_index];
                else 
                    decode <= keypad[16];                   
                if (delay_flag == 1'b1) begin
                    //decode <= decode;                  
                    nextState <= stateShift;                     //move to delay state
                end    
                else begin 
                    //decode <= decode;
                    nextState <= stateRead; 
                end                       
            end  
            stateShift : begin           
                ColType <= {ColType[0], ColType[3:1]};          //shift column
                col_tracker <= col_tracker + 1;                 //increment tracker
                decode <= decode;
                nextState <= stateWait;                         //move to delay state
            end
            default : begin
                ColType <= ColType;
                col_tracker <= col_tracker;
                decode <= decode;
                nextState <= stateInit;
            end                             
        endcase
    end     
end

/**** BUTTON READER BLOCKS ****/
//Determine index
assign key_index = ((state == stateRead) && (row != 4'b1111)) ? ((row + col_tracker) - sub) : 16;
/*
always @ (posedge clk) begin
    if  ((state == stateRead) && (row != 4'b1111))
        key_index <= (row + col_tracker) - sub;
    else 
        key_index <= key_index;    
end
*/
//Output Key value
/*
always @ (posedge clk) begin
    if  ((state == stateRead) && (row != 4'b1111))
        decode <= keypad[key_index];
    else if ((state == stateRead) && (row == 4'b1111))
        decode <= "?";    
    else 
        decode <= decode;    
end
*/
/****KEYPAD FLAG OUTPUT TO LCD CONTROLLER MODULE****/


endmodule