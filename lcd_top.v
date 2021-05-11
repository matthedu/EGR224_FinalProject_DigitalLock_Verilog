/*******************
*File :         lcd_top 
*Assignment:    Final Project
*Course:        EGR 224
*Instructor:    Professor Zuidema
*Author:        Dustin Matthews
*Date:          12/11/20
*Description:   Writes messages and key presses from keypad to the LCD 
********************/
`timescale 1ns / 1ps

module 
LCD_Upper_FSM  (clk_in, reset, keypad_flag, keypad_in, data_out, 
                rs_out, rw_out, e_out, PIN_index);
`define initIndex 5 
`define startIndex 14
`define matchIndex 15
`define invalidIndex 15
`define charDelay 26000
`define PT_MAX 4
///////////////////////////////
/******STATE PARAMETERS*******/
parameter   LCD_init = 4'b0000,
            write_Enter_PIN = 4'b0001,
            shift_Add_Line2 = 4'b0010,
            load = 4'b0011,
            write_Key = 4'b0100,
            idle = 4'b0101,
            return_Home = 4'b0110,            
            write_Match = 4'b0111,
            write_Invalid = 4'b1000,           
            done = 4'b1001;
//////////////////////////            
/*****KEYPAD LOADER******/            
parameter   load_3 = 2'b00,
            load_2 = 2'b01,    
            load_1 = 2'b10,
            load_0 = 2'b11;                    
///////////////////////////
/***** BUFFER *****/
parameter wait_for_press = 2'b00,
          halt = 2'b01,
          check_key_status = 2'b11;
//////////////////////////////////                       
input wire  clk_in, 
            reset,
            keypad_flag;

input wire [7:0] keypad_in;
output wire rs_out,
            e_out;
output wire [7:0] data_out;
output reg [1:0] PIN_index = 2'b11;
output reg rw_out = 0;

reg [20:0] delay_wire;
reg [20:0] buffer_count;
reg [7:0] load_key,
          data_wire;
reg [4:0] count = 0;
reg [3:0]  state = LCD_init;
reg [1:0]  buffer = wait_for_press;
reg [1:0]  load_PIN = load_1;

reg ready,
    rs_wire,
    start_out;
    
wire read,
     toggle,
     PIN_flag,
     idle_flag,
     count_flag,    
     complete_flag,
     wait_flag,
     check_PIN,
     finish_in,
     rs_assign;   
      
wire [7:0] data_assign;
wire [20:0] delay_assign;

reg [7:0] PIN_entry [3:0];
wire [7:0] data_cmd [6:0];
wire [20:0] delay_cmd [6:0];

wire [7:0] startMsg [`startIndex:0];
wire [7:0] matchMsg [`matchIndex:0];
wire [7:0] invalidMsg [`invalidIndex:0];
wire [31:0] system_PIN;

////////////////////////////////////////
//----------COMMAND ARRAYS------------//
////////////////////////////////////////
assign data_cmd[0] = 8'b00000000;/*00000000;*/  assign delay_cmd[0] = 20000;   //pwr on delay
assign data_cmd[1] = 8'b00111000;/*00000001;*/  assign delay_cmd[1] = 40;    //function set
assign data_cmd[2] = 8'b00001101;/*00000010;*/  assign delay_cmd[2] = 40;   //disp set
assign data_cmd[3] = 8'b00000001;/* 00000011;*/ assign delay_cmd[3] = 1600;   //disp clr
assign data_cmd[4] = 8'b00000010;/*00000100;*/  assign delay_cmd[4] = 1600;   //return home
assign data_cmd[5] = 8'b00000110;   /*increment display */ assign delay_cmd[5] = 40; 
assign data_cmd[6] = 8'b11000110;   assign delay_cmd[6] = 40;   //set cursor to second line address 46H 
////////////////////////////////////////
//----------CHARACTER ARRAYS----------//
////////////////////////////////////////
assign startMsg[0] =  "E";   assign matchMsg[0] =  "D";   assign invalidMsg[0] =   "I";          
assign startMsg[1] =  "n";   assign matchMsg[1] =  "o";   assign invalidMsg[1] =   "n";       
assign startMsg[2] =  "t";   assign matchMsg[2] =  "o";   assign invalidMsg[2] =   "v";
assign startMsg[3] =  "e";   assign matchMsg[3] =  "r";   assign invalidMsg[3] =   "a";
assign startMsg[4] =  "r";   assign matchMsg[4] =  " ";   assign invalidMsg[4] =   "l";   
assign startMsg[5] =  " ";   assign matchMsg[5] =  "i";   assign invalidMsg[5] =   "i";
assign startMsg[6] =  "4";   assign matchMsg[6] =  "s";   assign invalidMsg[6] =   "d";
assign startMsg[7] =  " ";   assign matchMsg[7] =  " ";   assign invalidMsg[7] =   " ";
assign startMsg[8] =  "d";   assign matchMsg[8] =  "U";   assign invalidMsg[8] =   "P";
assign startMsg[9] =  "i";   assign matchMsg[9] =  "n";   assign invalidMsg[9] =   "I";
assign startMsg[10] = "g";   assign matchMsg[10] = "l";   assign invalidMsg[10] =  "N";
assign startMsg[11] = " ";   assign matchMsg[11] = "o";   assign invalidMsg[11] =  " ";
assign startMsg[12] = "P";   assign matchMsg[12] = "c";   assign invalidMsg[12] =  " ";
assign startMsg[13] = "I";   assign matchMsg[13] = "k";   assign invalidMsg[13] =  " "; 
assign startMsg[14] = "N";   assign matchMsg[14] = "e";   assign invalidMsg[14] =  " ";
                             assign matchMsg[15] = "d";   assign invalidMsg[15] =  " "; 
/////////////////////////
//--SYSTEM PIN VALUE---//
/////////////////////////
assign system_PIN = "A49F";

/////////////////////////////////////////////
//Handshake with lower level LCD FSM MODULE//    
/////////////////////////////////////////////      
always @ (posedge clk_in) begin
    if ((finish_in == 1'b1) && (!idle_flag == 1'b1) && (!complete_flag == 1'b1))//(((finish_in == 1'b1) && (!idle_flag)) && (!complete_flag))// || (reset)) //(((finish_in == 1) && (!idle_flag) && (state != done)) || (reset == 1))
        start_out <= 1;
    else 
        start_out <= 0;
end
/////////////////////////////////////////////////////
//Ready goes high when ready to accept keypad input//
/////////////////////////////////////////////////////
always @ (posedge clk_in) begin
    if (((keypad_flag == 1'b1) || (wait_flag == 1'b1)) && (state == load))
        ready <= 1'b0;
    else 
        ready <= 1'b1;    
end
////////////////////////////////
//Data Feed to lower level FSM//
////////////////////////////////
always @ (posedge clk_in) begin 
    data_wire <= data_assign;
    delay_wire <= delay_assign;
    rs_wire <= rs_assign;
end 
///////////////////////////
//Top Level Index Counter//
///////////////////////////
always @ (posedge clk_in) begin
    if (reset == 1'b1)  
        count <= 3;         //RETURN HOME -> CLR DISP
    else if ((count_flag == 1'b1) || (idle_flag == 1'b1))           
        count <= 0;         //Stop/reset counter
    else if (toggle == 1'b1)    
        count <= count + 1;   
    else 
        count <= count;     
end
////////////
// BUFFER //
////////////
always @ (posedge clk_in) begin
    if (reset == 1'b1)
        buffer <= wait_for_press;
    else begin
        case (buffer) 
            wait_for_press : begin
                if (read == 1'b1) begin
                    buffer_count <= 0;
                    buffer <= halt;
                end
                else 
                    buffer <= wait_for_press;                       
            end
            ////////Ignore keypad while in halt
            halt : begin
                buffer_count <= buffer_count + 1;
                if (buffer_count == 500000)
                    buffer <= check_key_status;
                 else
                    buffer <= halt;   
            end
            ////////Check if key is still pressed
            check_key_status : begin
                if (keypad_flag == 1'b1) begin
                    buffer_count <= 0;
                    buffer <= halt;
                end
                else 
                    buffer <= wait_for_press;    
            end
            default : begin
                buffer <= wait_for_press;
            end
        endcase
    end    
end
//////////////
//PIN LOADER//
//////////////
always @ (posedge clk_in) begin
    if (reset) begin            //reset the PIN index
        load_PIN <= load_3;
        PIN_index <= 3;
    end    
    else if ((read == 1'b1) && (state == load)) begin
    //Keypad toggled, load value into PIN array
        case (load_PIN)
            load_3 : begin
                PIN_entry[3] <= keypad_in;
                load_PIN <= load_2;
                PIN_index <= 3;
                               
            end  
            load_2 : begin
                PIN_entry[2] <= keypad_in;
                load_PIN <= load_1;             
                PIN_index <= 2;
                
            end    
            load_1 : begin
                PIN_entry[1] <= keypad_in;
                load_PIN <= load_0;
                PIN_index <= 1;                
            end
            load_0 : begin
                PIN_entry[0] <= keypad_in;
                load_PIN <= load_PIN;
                PIN_index <= 0;                               
            end        
        endcase  
    end
    else begin    
        load_PIN <= load_PIN; 
        PIN_index <= PIN_index;
    end           
end

/////////////////////////////       
//FSM TO CONTROL LCD OUTPUT//
/////////////////////////////                      
always @ (posedge clk_in) begin
    if (reset == 1'b1)
        state <= LCD_init;
    else begin     
        case (state)
            /////////initialize LCD
            LCD_init : begin         
                if (count_flag == 1'b1) 
                    state <= write_Enter_PIN;
                else 
                    state <= LCD_init;
            end
            /////////Write first display message
            write_Enter_PIN : begin               
                if (count_flag == 1'b1) begin
                    state <= shift_Add_Line2;
                end    
                else 
                    state <= write_Enter_PIN;
            end
            ////////Set address to line 2
            shift_Add_Line2 : begin
                if (count_flag == 1'b1)
                    state <= load;    
                else 
                    state <= shift_Add_Line2;
            end 
            ////////wait for Keypress 
            load : begin
                if (read == 1'b1)
                    state <= write_Key;
                else 
                    state <= load;    
            end
            ////////Write keypress to the LCD
            write_Key : begin
                if (count_flag == 1'b1)
                    state <= idle;   
                else
                    state <= write_Key;
            end
            ////////Idle until ready for next input
            ////////or if 4 digits entered, return LCD home
            idle : begin
                if (PIN_flag == 1'b1) 
                    state <= return_Home;     
                else if (ready == 1'b1)
                    state <= load;                      
                else 
                    state <= idle;    
            end 
            ////////set LCD address home, check if PIN matches
            return_Home : begin
                if (count_flag == 1'b1) begin    
                    if (check_PIN == 1'b1)
                        state <= write_Match;
                    else 
                        state <= write_Invalid; 
                end
                else
                    state <= return_Home;
            end            
            ////////PIN valid, unlock door
            write_Match : begin
                if (count_flag == 1'b1)
                    state <= done;
                else     
                    state <= write_Match;
            end
            ////////PIN invalid, display error msg
            write_Invalid : begin
                if (count_flag == 1'b1)
                    state <= done;
                else     
                    state <= write_Invalid;
            end         
            ////////show message until reset         
            done : begin
                state <= done;
            end      
            ////////
            default : begin
                state <= LCD_init;
            end   
        endcase
    end        
end
////////////////////
//Lower LCD Module//
////////////////////
LCD_FSM sm1 (.e(e_out), .rs(rs_out), .data(data_out), .clk(clk_in), .reset(reset), 
.start(start_out), .finish(finish_in), .data_in(data_wire), .rs_in(rs_wire), .delay_in(delay_wire));
////////////////////
//FLAG ASSIGNMENTS//
////////////////////
//FLAG for top level index counter//
assign count_flag =     (                    
                        ((state == LCD_init)        &&  (count == `initIndex + 1))   ||
                        ((state == write_Enter_PIN) &&  (count == `startIndex +1))   ||
                        ((state == shift_Add_Line2) &&  (count == 1))                ||
                        ((state == return_Home)     &&  (count == 2))                ||                         //NEW NEW NEW
                        ((state == write_Match)     &&  (count == `matchIndex + 1))  ||
                        ((state == write_Invalid)   &&  (count == `invalidIndex + 1))||
                        ((state == write_Key)       &&  (count == 1))                             
                        ) ? 1'b1 : 1'b0;
                        
//FLAG to idle the LCD//
assign idle_flag =  (
                    ((state == idle) && (!PIN_flag == 1'b1))  ||
                    (state == load)
                    )    ? 1'b1 : 1'b0;
//FLAG goes high if 4 PIN digits received
assign PIN_flag = (PIN_index == 1'b0) ? 1'b1 : 1'b0;     
//FLAG goes high while ignoring keypad 
assign wait_flag = ((buffer == halt) || 
                    (buffer == check_key_status)
                    ) ? 1'b1 : 1'b0;
//FLAG goes high if all tasks completed                    
assign complete_flag = ((state == done) && (!reset)) ? 1'b1 : 1'b0;                        
//FLAG goes high if entered PIN matches stored PIN//
assign check_PIN = (
                   ((PIN_index == 1'b0) && 
                   ({PIN_entry[3], PIN_entry[2],
                     PIN_entry[1], PIN_entry[0]} == system_PIN))
                    ) ? 1'b1 : 1'b0;    
///////////////////////////////////////                        
//Data assignments to lower level FSM//
assign data_assign =    (state == LCD_init)         ? data_cmd[count] :
                        (state == write_Enter_PIN)  ? startMsg[count] :
                        (state == shift_Add_Line2)  ? data_cmd[6] : 
                        (state == write_Key)        ? PIN_entry[PIN_index] :
                        (state == return_Home)      ? data_cmd[4] :
                        (state == write_Match)      ? matchMsg[count] :    
                        (state == write_Invalid)    ? invalidMsg[count]:
                        0;                        
assign delay_assign =   (state == LCD_init)         ? delay_cmd[count] :
                        (state == write_Enter_PIN)  ? `charDelay       :
                        (state == shift_Add_Line2)  ? delay_cmd[6]     :
                        (state == write_Key)        ? `charDelay :
                        (state == return_Home)      ? delay_cmd[4] :
                        (state == write_Match)      ? `charDelay :    
                        (state == write_Invalid)    ? `charDelay :
                        0;                          
assign rs_assign =      (state == LCD_init)         ? 1'b0 :
                        (state == write_Enter_PIN)  ? 1'b1 :
                        (state == shift_Add_Line2)  ? 1'b0 :
                        (state == write_Key)        ? 1'b1 :
                        (state == return_Home)      ? 1'b0 :
                        (state == write_Match)      ? 1'b1 :    
                        (state == write_Invalid)    ? 1'b1 :                   
                        0;                                          
/////////////////////////////////////
//READ FLAG toggles high for one clock cycle to load keypad value
assign read = ((ready == 1'b1) && (keypad_flag == 1'b1)) ? 1'b1 : 1'b0;
//TOGGLE flag toggles high for one clock cycle to increment top counter
assign toggle = (start_out & finish_in) ? 1'b1 : 1'b0;

endmodule
