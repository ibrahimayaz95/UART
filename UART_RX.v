`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Engineer: IBRAHIM AYAZ
// 
// Create Date: 18.11.2020 14:37:29
// Design Name: UART RECEIVER
// Module Name: UART_RX
// Revision 0.01 - File Created

/*UART
------------------------------------------------------------------
-Stands for Universal Asynchronous Receiver/Transmitter
-Full Duplex
-Since there is no clock in this type of communication, Receiver and Transmitter should
need a Baud Rate for understanding each other. In example 9600, 19200, 115200 etc.
-8 bits (1 Byte) of Data
-LSB first type communication. Start Bit - Bit0 - Bit1 - ... - Bit7 - Stop Bit

UART RECEIVER
------------------------------------------------------------------
Create a UART Receiver that receives a byte from the computer and displays it on the
7-Segment Display (2 digit is enough). The UART receiver should operate at 115200 baud rate,
8 data bits (1 byte), no parity bit, 1 stop bit, no flow control. After that create a UART transmitter to send same data
to the computer.

Make two module seperately which are UART Receiver(RX) and Binary To 7-Segment Converter
than instantiate them on a top module.

We have 4 states;
1. IDLE
2. START
3. DATA SEND
4. STOP

We need to create counter for the Baud Rate management which calculates as CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
Example: 25 MHz Clock, 115200 baud UART
(25000000)/(115200) = 217
Declare this as a parameter.

We need to make calculations at the middle part of every bit.
*/

module UART_RX
#(
parameter CLKS_PER_BIT = 868		//100000000(100 Mhz Clock) / 115200(Desired Baud Rate) = 868
)
(
input i_Clk,			//Clock
input i_RX_Serial,		//Serial Data
output o_RX_DV,			//Data Valid
output [7:0] o_RX_Byte	//Parallel Data
);

//States
//3 bits represent states by number.
   parameter [2:0] IDLE = 3'b000        ,	//Default State         
                RX_START_BIT = 3'b001   ,	//Start bit's State 
                RX_DATA_BITS = 3'b010   , 	//Data's State
                RX_STOP_BIT = 3'b011    ,	//Stop bit's State  
                CLEANUP = 3'b100        ;   //This state is for returning to the Default State after 1 clock cycle



reg [9:0] r_Clock_Count = 0;			//Counter for sampling data
reg r_RX_DV = 1'b0;						//Stop bit variable
reg [7:0] r_RX_BYTE = 0;				//Variable for the Recieved data as byte domain 
reg [2:0] r_Bit_Index = 0;				//Index counter variable for receiving data
reg [2:0] r_State = 0;					//State variable




	always@(posedge i_Clk)
		begin
			case(r_State)
				IDLE :					// Default State
					begin
						r_Clock_Count <= 0;
						r_Bit_Index <= 0;
						r_RX_DV <= 1'b0;
						
						if(i_RX_Serial == 1'b0)
							r_State <= RX_START_BIT;
						else
							begin
							r_State <= IDLE;
							end
					end
					
				RX_START_BIT:			//Start bit must be 1'b0 because by default flow is 1'b1	
					begin
						if(r_Clock_Count == (CLKS_PER_BIT-1)/2)		//We are sampling from the middle of the first bit, just to make sure we are ignoring timing issues.
							begin
								if(i_RX_Serial == 1'b0)
									begin
										r_Clock_Count <= 0;
										r_State <= RX_DATA_BITS;
									end
								else
									r_State <= IDLE;	
							end
						else
							begin
								r_Clock_Count <= r_Clock_Count + 1;
								r_State <= RX_START_BIT;
							end
					end
					
				RX_DATA_BITS:			//Data Receiver Algorithm
					begin
						if(r_Clock_Count < CLKS_PER_BIT-1)		//We were on the middle of the first bit and now, we are on the middle of the next bit which is the first bit of Data bits.
							begin
								r_Clock_Count <= r_Clock_Count + 1;
								r_State <= RX_DATA_BITS;
							end
						else
							begin
								r_Clock_Count <= 0;
								r_RX_BYTE[r_Bit_Index] <= i_RX_Serial;	//We are creating an output BYTE by writing every index of bit one by one.
								
								if(r_Bit_Index <7)
									begin
										r_Bit_Index <= r_Bit_Index + 1;
										r_State <= RX_DATA_BITS;
									end
								else
									begin
										r_Bit_Index <= 0;
										r_State <= RX_STOP_BIT;
									end
							end
					end
					
				RX_STOP_BIT:			//Stop bit Action
					begin
						if(r_Clock_Count < CLKS_PER_BIT-1)
							begin
								r_Clock_Count <= r_Clock_Count + 1;
								r_State <= RX_STOP_BIT;
							end
						else
							begin
								r_RX_DV <= 1'b1;
								r_Clock_Count <= 0;
								r_State <= CLEANUP;
								
							end
					end
				//This is for 1 clock cycle delay and returning to the default flow				
				CLEANUP:
					begin
						r_RX_DV <= 1'b0;
						r_State <= IDLE;
					end
				default:
				r_State <= IDLE;
			endcase
		end

assign o_RX_Byte = r_RX_BYTE;		//Assigning registered value to the output
assign o_RX_DV = r_RX_DV;

endmodule
