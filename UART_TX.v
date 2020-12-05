`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: IBRAHIM AYAZ
// 
// Create Date: 20.11.2020 15:13:10
// Design Name: UART TRANSMITTER
// Module Name: UART_TX
// Revision 0.01 - File Created

/*UART TRANSMITTER
-----------------------------
It will be the exact opposite of UART Receiver. 
It means that the algorithm, outputs and inputs will be vice versa.
*/

module UART_TX
#
(
parameter CLKS_PER_BIT = 868		//100000000(100 Mhz Clock) / 115200(Desired Baud Rate)
)
(
input i_Clk,
input i_TX_DV,						//Data Valid
input [7:0] i_TX_BYTE,				//Parallel Data
output reg o_TX_SERIAL,				//Serial Data
output o_TX_ACTIVE,					//Information for TRANSMITTER being active
output o_TX_DONE					//Information for Transmitting process being done
);

parameter [2:0] IDLE = 3'b000;			//Default State 
parameter [2:0] START_BIT = 3'b001;		//Start bit's State 
parameter [2:0] DATA_BITS = 3'b010;		//Data's State
parameter [2:0] STOP_BIT = 3'b011;		//Stop bit's State
parameter [2:0] CLEANUP = 3'b100;		//This state is for returning to the Default State after 1 clock cycle

reg [2:0] r_STATE = 0;					//State Variable
reg [9:0] r_Clock_Count = 0;			//Counter for sampling data
reg [2:0] r_BIT_INDEX = 0;				//Index counter variable for receiving data
reg [7:0] r_TX_BYTE = 0;				//Variable which will be transmitted data as byte domain
reg r_TX_ACTIVE = 0;					//Registered information for TRANSMITTER being active
reg r_TX_DONE = 0;						//Registered information for Transmitting process being done


//Opposite algorithm of UART Receiver

always@(posedge i_Clk)
	begin
		case(r_STATE)
			IDLE:
				begin
					r_Clock_Count <= 0;
					r_BIT_INDEX <= 0;
					r_TX_DONE <= 1'b0;
					o_TX_SERIAL <= 1'b1;
					
					if(i_TX_DV == 1'b1)
						begin
							r_TX_ACTIVE <= 1'b1;
							r_TX_BYTE <= i_TX_BYTE;
							r_STATE <= START_BIT;
						end
					else
						r_STATE <= IDLE;
				end
			START_BIT:
				begin
					o_TX_SERIAL <= 1'b0;
					
					if(r_Clock_Count < CLKS_PER_BIT -1)
						begin
							r_Clock_Count <= r_Clock_Count + 1;
							r_STATE <= START_BIT;	
						end
					else
						begin
							r_Clock_Count <= 0;
							r_STATE <= DATA_BITS;
						end
				end
			DATA_BITS:
				begin
					o_TX_SERIAL <= r_TX_BYTE[r_BIT_INDEX];
					
					if(r_Clock_Count < CLKS_PER_BIT -1)
						begin
							r_Clock_Count <= r_Clock_Count + 1;
							r_STATE <= DATA_BITS;
						end
					else
						begin
							r_Clock_Count <= 0;
							if(r_BIT_INDEX < 7)
								begin
									r_BIT_INDEX <= r_BIT_INDEX + 1;
									r_STATE <= DATA_BITS;
								end
							else
								begin
									r_BIT_INDEX <= 0;
									r_STATE <= STOP_BIT;
								end
						end
				end
			STOP_BIT:
				begin
					o_TX_SERIAL <= 1'b1;
						if(r_Clock_Count < CLKS_PER_BIT -1)
							begin
								r_Clock_Count <= r_Clock_Count + 1;
								r_STATE <= STOP_BIT;
							end
						else
							begin
								r_Clock_Count <= 0;
								r_STATE <= CLEANUP;
								r_TX_DONE <= 1'b1;
								r_TX_ACTIVE <= 1'b0;
							end
				end
			CLEANUP:
				begin
					r_STATE <= IDLE;
					r_TX_DONE <= 1'b1;
				end
			default:
				r_STATE <= IDLE;
		endcase
	end
	
assign o_TX_ACTIVE = r_TX_ACTIVE;
assign o_TX_DONE = r_TX_DONE;

endmodule

 	