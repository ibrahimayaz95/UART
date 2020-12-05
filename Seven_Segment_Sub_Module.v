`timescale 1ns / 1ps

// Seven Segment Display Sub Module

module Seven_Segment_Sub_Module
(
input i_Clk,			//Clock
input [3:0] Count,		//State Counter
output o_Segment_A,		//These are the Segments of one digit, Seven Segment Display
output o_Segment_B,	
output o_Segment_C,
output o_Segment_D,	
output o_Segment_E,
output o_Segment_F,
output o_Segment_G				
);

reg [6:0] Display = 0; //Variable for the Segment display

/*
Nexys 4 DDR Board Seven Segment Display
--------------------------------------------------------------------------------------------------------------------------------------
On every segment, there is one common anode which is considered as high.
So in order to light a segment, you need to pull the cathode to low.
On assigning stage we are assigning each segment to one bit of Display array which means MSB of a binary number will be "a" and LSB of
same binary number will be "g" --> abcdefg
For instance, in the first state All segments will lightened up except "g", which makes seven segment display, displays a "0".
*/

always@(posedge i_Clk)
	begin
		case(Count)
			4'b0000: Display <= 7'b0000001;		//0
			4'b0001: Display <= 7'b1001111;		//1		
			4'b0010: Display <= 7'b0010010;		//2 	
			4'b0011: Display <= 7'b0000110; 	//3
			4'b0100: Display <= 7'b1001100; 	//4
			4'b0101: Display <= 7'b0100100; 	//5
			4'b0110: Display <= 7'b0100000; 	//6
			4'b0111: Display <= 7'b0001111; 	//7
			4'b1000: Display <= 7'b0000000; 	//8 
			4'b1001: Display <= 7'b0000100;		//9
			4'b1010: Display <= 7'b0000010;		//A
			4'b1011: Display <= 7'b1100000;		//B		
			4'b1100: Display <= 7'b0110001;		//C
			4'b1101: Display <= 7'b1000010;		//D
			4'b1110: Display <= 7'b0110000;		//E
			4'b1111: Display <= 7'b0111000;		//F
			default: Display <= 7'b0000001;		//0 	
		endcase
	end

assign o_Segment_A = Display[6];				//Segment A
assign o_Segment_B = Display[5];				//Segment B
assign o_Segment_C = Display[4];				//Segment C
assign o_Segment_D = Display[3];				//Segment D
assign o_Segment_E = Display[2];				//Segment E
assign o_Segment_F = Display[1];				//Segment F
assign o_Segment_G = Display[0];				//Segment G


endmodule