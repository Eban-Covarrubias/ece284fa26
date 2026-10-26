// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
module mac (out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;

output signed [psum_bw-1:0] out;
input  [bw-1:0] a; //unsigned activation 0 to 15
input  signed [bw-1:0] b;
input  signed [psum_bw-1:0] c;

wire signed [bw:0]     a_s;      // a with a 0 on top: 5-bit signed, still 0 to 15
wire signed [2*bw:0]   product;  // 5-bit x 4-bit signed fits in 9 bits: -120 to 105

// Prepending 0 keeps a positive. Without it, an unsigned a would make the whole expression unsigned
assign a_s     = {1'b0, a};
assign product = a_s * b;        // both operands signed -> signed multiply
assign out = c + product;    // both signed -> product is sign-extended to 16 bits

endmodule
