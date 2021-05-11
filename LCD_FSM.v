/*******************
*File :         LCD_FSM 
*Assignment:    Lab 8
*Course:        EGR 224
*Instructor:    Professor Zuidema
*Author:        Dustin Matthews
*Date:          11/13/20
*Description:   work_state Machine to send data to LCD 
********************/
`timescale 1ns / 1ps

module 
LCD_FSM(e, rs, data, clk, reset, start, finish, data_in, rs_in, delay_in);
//INPUTS
input clk, reset;
input start;            // flag to start work_state machine and process data
input rs_in;            //determines command or data write
input [7:0] data_in;    // data sent from top level for FSM to process
input [20:0] delay_in;  // delay length sent from top level
//OUTPUTS
output reg e, rs;       //signals sent out from module
output reg [7:0] data;  //data sent out from module
output reg finish;      // flag to top level to signal data has been sent

//REGISTERS
reg [20:0] delay_current; 
reg [20:0] delay_set;
wire delay_flag;
//work_state VARIABLES
parameter work_stateBegin = 4'b0001, 
          work_stateSetData = 4'b0010, 
          work_stateEnLow = 4'b0100, 
          work_stateDelay = 4'b1000; 
          
reg [3:0] work_state = work_stateBegin;

//delay flag goes high if work_state is work_stateDelay and the delay counter matches the delay_set variable    
assign delay_flag = ((work_state == work_stateDelay) && (delay_set == delay_current)) ? 1'b1 : 1'b0; 

//current delay count will set to zero if work_state is not work_stateDelay or delay flag goes high
always @(posedge clk)
    begin
        if ((delay_flag == 1) || (work_state != work_stateDelay)) begin 
            delay_current <= 0;
        end
        else begin
            delay_current <= (delay_current + 1);
        end
    end
   
always @(posedge clk)
    begin 
        if (reset) begin
            data <= 0;
            finish <= 1;
            work_state <= work_stateBegin;
            rs <= 0;
            e <= 1;
            delay_set <= 0;
            end
        else begin
        case(work_state)
            work_stateBegin : begin
                if (start && finish) begin
                    data <= data_in;        //load data input
                    rs <= rs_in;            //assign the rs value
                    e <= 1;
                    finish <= 0;
                    delay_set <= delay_in;  //assign the delay value
                    work_state <= work_stateSetData;
                end
                /* IDLE UNTIL START IN GOES HIGH */
                else begin 
                    data <= data;           
                    rs <= rs;
                    e <= 1;
                    finish <= 1;            //set finish high, which will set start high in top level
                    delay_set <= delay_set;
                    work_state <= work_stateBegin;
                end
            end
            work_stateSetData : begin
                    data <= data;               
                    rs <= rs;
                    e <= 1;
                    finish <= 0;                //set finish LOW
                    delay_set <= delay_set;
                    work_state <= work_stateEnLow;
            end
            work_stateEnLow : begin
                    data <= data;
                    rs <= rs;
                    e <= 0;                     //drive E LOW  to lock in data
                    finish <= 0;
                    delay_set <= delay_set;
                    work_state <= work_stateDelay;
            end 
            work_stateDelay : begin              //remain in this work_state until the delay is complete
                if (delay_flag == 1'b1) begin 
                    data <= data;
                    rs <= rs;
                    e <= e;
                    finish <= 0;
                    delay_set <= delay_set;
                    work_state <= work_stateBegin;
                    end
                else begin
                    data <= data;
                    rs <= rs;
                    e <= e;
                    finish <= 0;
                    delay_set <= delay_set;
                    work_state <= work_stateDelay;
                    end    
            end
            default : work_state <= work_stateBegin;
        endcase    
    end         
end                   
endmodule

