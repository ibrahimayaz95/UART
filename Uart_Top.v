`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: IBRAHIM AYAZ 
// 
// Create Date: 20.11.2020 15:13:10
// Design Name: UART_TOP_MODULE
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module Uart_Top(
input i_Clk,						 //Clock
input i_UART_RX,					 //Received Data Input

output o_UART_TX,					 //Transmitted Data Output
output reg o_Segment_A,				 //These are the Segments of one digit, Seven Segment Display
output reg o_Segment_B,
output reg o_Segment_C,
output reg o_Segment_D,
output reg o_Segment_E,
output reg o_Segment_F,
output reg o_Segment_G,

output reg [7:0] o_Anode			 //Variable for Anode Output	
 );

parameter c_CLKS_PER_BIT = 868;		//100000000(100 Mhz Clock) / 115200(Desired Baud Rate) = 868

wire w_RX_DV;						//Receiver's Data Valid connection
wire [7:0] w_RX_Byte;				//Receiver's Data Byte connection
wire w_TX_SERIAL;					//Serial Data connection from Transmitter
wire w_TX_ACTIVE;					//Active information of Transmitter connection

UART_RX								//Instantiation of Receiver 
#
(
.CLKS_PER_BIT(c_CLKS_PER_BIT)
)
Inst_1
(
.i_Clk(i_Clk),
.i_RX_Serial(i_UART_RX),		
.o_RX_DV(w_RX_DV),
.o_RX_Byte(w_RX_Byte)	
);


UART_TX 							//Instantiation of Transmitter 
#
(
.CLKS_PER_BIT(c_CLKS_PER_BIT)
)
Inst_2
(
.i_Clk(i_Clk),
.i_TX_DV(w_RX_DV),						
.i_TX_BYTE(w_RX_Byte),
.o_TX_SERIAL(w_TX_SERIAL),
.o_TX_ACTIVE(w_TX_ACTIVE),
.o_TX_DONE()
);

assign o_UART_TX = w_TX_ACTIVE ? w_TX_SERIAL : 1'b1; //If Information for TRANSMITTER being active is high, send the bit otherwise send 1 which is default flow of UART.

wire w_Segment1_A, w_Segment2_A;	//Segment connections of both Digits
wire w_Segment1_B, w_Segment2_B;
wire w_Segment1_C, w_Segment2_C;
wire w_Segment1_D, w_Segment2_D;
wire w_Segment1_E, w_Segment2_E;
wire w_Segment1_F, w_Segment2_F;
wire w_Segment1_G, w_Segment2_G;

Seven_Segment_Sub_Module Inst_3		//Instantiation of the first digit		
(
.i_Clk(i_Clk),
.Count(w_RX_Byte[7:4]),				//First Digit will Display Numbers of the BYTE's 7'th to 4'th digits.
.o_Segment_A(w_Segment1_A),
.o_Segment_B(w_Segment1_B),
.o_Segment_C(w_Segment1_C),
.o_Segment_D(w_Segment1_D),
.o_Segment_E(w_Segment1_E),
.o_Segment_F(o_Segment1_F),
.o_Segment_G(w_Segment1_G)
);

Seven_Segment_Sub_Module Inst_4		//Instantiation of the second digit		
(
.i_Clk(i_Clk),
.Count(w_RX_Byte[3:0]),				//Second Digit will Display Numbers of the BYTE's 3'rd to 0'th digits.
.o_Segment_A(w_Segment2_A),
.o_Segment_B(w_Segment2_B),
.o_Segment_C(w_Segment2_C),
.o_Segment_D(w_Segment2_D),
.o_Segment_E(w_Segment2_E),
.o_Segment_F(w_Segment2_F),
.o_Segment_G(w_Segment2_G)
);

/*
On Nexsy 4 DDR, there are 8 anode connections for each digit of Seven Segment Display
which connected through PNP transistor for each of it.
So that means, we need to set the pin low in order to manage PNP transistor flows the current to anode.
In order to Display different numbers on different digits, we need to set one pin low at a time and after some amount of time we need
to set the other pin low while setting the former pin to high again.
We need to do this by creating a counter which counts to a number that human eye will see that 2 digit's are displaying all the time.
*/

reg [19:0] Mounter = 0;			//Yes, I have just created a counter which named as Mounter :D
parameter MOUNT = 1000000;		//This is the counter
always@(posedge i_Clk)
begin
Mounter <= Mounter + 1;
if(Mounter < MOUNT)
begin
if(Mounter < MOUNT / 2)			//First 500000 count for displaying first digit
begin
o_Anode <= 8'b01111111;
o_Segment_A <= w_Segment1_A;	//Sending segment information to output ports
o_Segment_B <= w_Segment1_B;
o_Segment_C <= w_Segment1_C;
o_Segment_D <= w_Segment1_D;
o_Segment_E <= w_Segment1_E;
o_Segment_F <= o_Segment1_F;
o_Segment_G <= w_Segment1_G;
end
else 
begin
o_Anode <= 8'b10111111;			//Second 500000 count for displaying second digit
o_Segment_A <= w_Segment2_A;	//Sending segment information to output ports
o_Segment_B <= w_Segment2_B;
o_Segment_C <= w_Segment2_C;
o_Segment_D <= w_Segment2_D;
o_Segment_E <= w_Segment2_E;
o_Segment_F <= w_Segment2_F;
o_Segment_G <= w_Segment2_G;
end
end
else
Mounter <= 0;					
end 
 
endmodule
