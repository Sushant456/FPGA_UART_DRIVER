`timescale 1ns / 1ps

//--------------------------------------------------------------------//
// MimasV2 UART RTL Sample Code
// Numato Lab
// http://www.numato.com
// http://www.numato.cc
// License : CC BY-SA (http:-creativecommons.org/licenses/by-sa/2.0/)
//--------------------------------------------------------------------//

module top_module(tx,rx,clk,reset);

output tx;
input rx,clk,reset;

localparam [1:0] idle=2'b00, data1=2'b01, data2=2'b10, data3=2'b11;

    // Signals for UART submodule 
    reg        rd_uart   = 1'b0;
    reg        wr_uart   = 1'b0;
    reg  [7:0] data_out  = 0   ;   
    wire [7:0] data_in         ;    
    wire       full            ;
    wire       empty           ;
    reg  [7:0] data_rx   = 0   ;
	 reg  [1:0] rx_state  = 0   ;

    reg  [9:0] disp_num  = 0	 ;
    reg  [9:0] disp_num1 = 0	 ;	 
	 wire [3:0] dig0,dig1,dig2  ;
	 reg  [3:0] currentDig       ;
	 reg  [1:0] digCnt = 2'd0    ;
	 reg  dig0en,dig1en,dig2en;
	 assign e1=dig2en; assign e2=dig1en; assign e3=dig0en;
	 reg  [15:0] dispClk = 0     ;

//bin2BCD v1({dig2,dig1,dig0},disp_num1);
//BCDto7Seg v2(a,b,c,d,e,f,g,h,currentDig);

	
    // Counter to set the time delay
    reg [26:0] timer_cnt      = 0;    
    reg        timer_timeout  = 1'b0;
    
    // Parameters for memory
    parameter   WIDTH     =   8 ,
                DEPTH     =   20,
                ADDR      =   4 ;
                 
    // Ram & address
    reg  [ADDR-1:0] address   = 0   ;
    wire [WIDTH-1:0] arr_mem [DEPTH-1:0];
    
    // Assuming clk frequency 100MHz
    parameter CLK_FREQ = 100000000;
    
    // Assigning data to ram memory 
    assign  arr_mem[0]  =   "1";
    assign  arr_mem[1]  =   "9";
    assign  arr_mem[2]  =   ".2";        
    assign  arr_mem[3]  =   ".3";         
    assign  arr_mem[4]  =   "5";        
    assign  arr_mem[5]  =   " ";         
    assign  arr_mem[6]  =   "7";        
    assign  arr_mem[7]  =   "3";         
    assign  arr_mem[8]  =   ".1";         
    assign  arr_mem[9]  =   ".1";        
    assign  arr_mem[10] =   "7";        
    assign  arr_mem[11] =   " "; 
	 assign  arr_mem[12]  =   "\n";         
    assign  arr_mem[13]  =   "\r";        
    assign  arr_mem[14] =   "7";        
    assign  arr_mem[15] =   " ";	 
    assign  arr_mem[16] =   "\n";      //  new line character
    assign  arr_mem[17] =   "\r";     //  carriage return character 
    
    // Timer logic 
    always@(posedge clk)
    begin
        if(!reset)
            timer_cnt   <=  0;
        else if(timer_cnt == CLK_FREQ-1) // 99999999 = 1s , we are setting some delay to display string next time. 
        begin
            timer_timeout    <=  1'b1;
            timer_cnt        <=  0;
        end
        else if(address == 13)
            timer_timeout    <=  0; 
        else
            timer_cnt   <=  timer_cnt + 1'b1;
    end
    
    // writing data to uart and incrementing address for memory 
    always@(posedge clk)
    begin
        if(!reset)
        begin
            data_out     <=  0;
            address     <=  0;
        end
        else if(timer_timeout && ~full)
        begin
            wr_uart     <=  1'b1;
            data_out     <=  arr_mem[address];
            address     <=  address + 1'b1;
            if(address == 13)
                address <=  0;
        end
        else
            wr_uart     <=  1'b0;
    end                                             
    
	 always @(posedge timer_cnt[10] or negedge reset) 
	 begin
	 if(!reset) 
	  begin
	   rx_state<=idle;
		disp_num<=0;
		disp_num1<=0;
	  end
	 else
	  begin 
		 if(!empty) 
			 begin
				rd_uart <= 1'b1;
				data_rx <= data_in;		
				case(rx_state)
					idle: begin
					if(data_rx!="\r" && data_rx>="0" && data_rx<="9") begin rx_state<=data1; disp_num<=data_rx-"0"; end
					end
					data1: begin
					if(data_rx!="\r" && data_rx>="0" && data_rx<="9") begin rx_state<=data2; disp_num<=4'd10*disp_num + (data_rx-"0"); end
					else if(data_rx=="\r") begin rx_state<=idle; disp_num1<=disp_num; disp_num<=0; end
					else begin rx_state<=idle; disp_num<=0; end
					end
					data2: begin
					if(data_rx!="\r" && data_rx>="0" && data_rx<="9") begin rx_state<=data3; disp_num<=4'd10*disp_num + (data_rx-"0"); end
					else if(data_rx=="\r") begin rx_state<=idle; disp_num1<=disp_num; disp_num<=0; end
					else begin rx_state<=idle; disp_num<=0; end				
					end
					data3: begin
					if(data_rx!="\r") begin rx_state<=idle; disp_num<=0; end
               else begin rx_state<=idle; disp_num1<=disp_num; disp_num<=0; end					
					end				
            endcase
			 end
		 else
		    rd_uart<=1'b0;
	  end
	 end
	 
	always @(posedge clk or negedge reset) begin
	if(!reset) dispClk <= 16'd0;
	else dispClk <= dispClk + 1'b1;
	end 

	always @(posedge dispClk[15]) begin
		case (digCnt)
			2'd0: begin
			digCnt <= 2'd1;
			dig2en <= 1'b1;dig1en <= 1'b1;dig0en <= 1'b0; 
			currentDig <= dig0;
			end
			2'd1: begin
			digCnt <= 2'd2;
			if(dig1==4'd0 & dig2==4'd0) begin dig2en <= 1'b1;dig1en <= 1'b1;dig0en <= 1'b1; end 
			else begin dig2en <= 1'b1;dig1en <= 1'b0;dig0en <= 1'b1; currentDig <= dig1; end
			end
			2'd2: begin
			digCnt <= 2'd0;
			if(dig2==4'd0) begin dig2en <= 1'b1;dig1en <= 1'b1;dig0en <= 1'b1; end
			else begin dig2en <= 1'b0;dig1en <= 1'b1;dig0en <= 1'b1; currentDig <= dig2; end
			end
		endcase
	end
	 
    // Instantiation of uart module
    // DIVISOR = 326 for 19200 baudrate, 100MHz sys clock
    uart #(     .DIVISOR		(9'd326),   
                .DVSR_BIT		(4'd9)	,
                .Data_Bits		(4'd8)	,
                .FIFO_Add_Bit	(3'd4)
    ) uart (    .clk			   (clk),
                .rd_uart		(rd_uart)	,
                .reset			(reset)		,	
                .rx				(rx)		,
                .w_data			(data_out)	,
                .wr_uart		(wr_uart)	,
                .r_data			(data_in)	,
                .rx_empty		(empty)		,
                .tx				(tx)		,
                .tx_full		(full)
           );             
endmodule
