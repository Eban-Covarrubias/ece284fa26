// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
module mac (out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;

// psum_out = psum_in + x0*w0 + x1*w1 + x2*w2 + x3*w3, all in one cycle (combinational)
output signed [psum_bw-1:0] out;
input         [4*bw-1:0] a;   // 4 activations packed: x0 = a[3:0], x1 = a[7:4], ... (unsigned, 0 to 15)
input         [4*bw-1:0] b;   // 4 weights packed:     w0 = b[3:0], w1 = b[7:4], ... (signed, -8 to 7)
input  signed [psum_bw-1:0] c;  // psum_in

// unpack, and give each activation a 0 on top so it stays positive as a signed number (same trick as Q2)
wire signed [bw:0]   x0 = {1'b0, a[1*bw-1:0*bw]};
wire signed [bw:0]   x1 = {1'b0, a[2*bw-1:1*bw]};
wire signed [bw:0]   x2 = {1'b0, a[3*bw-1:2*bw]};
wire signed [bw:0]   x3 = {1'b0, a[4*bw-1:3*bw]};
wire signed [bw-1:0] w0 = b[1*bw-1:0*bw];
wire signed [bw-1:0] w1 = b[2*bw-1:1*bw];
wire signed [bw-1:0] w2 = b[3*bw-1:2*bw];
wire signed [bw-1:0] w3 = b[4*bw-1:3*bw];

// 4 multipliers in parallel: unsigned 4-bit x signed 4-bit = -120 to 105, fits in 2B = 8 signed bits
wire signed [2*bw-1:0] p0 = x0 * w0;
wire signed [2*bw-1:0] p1 = x1 * w1;
wire signed [2*bw-1:0] p2 = x2 * w2;
wire signed [2*bw-1:0] p3 = x3 * w3;

// adder tree, level 1: two pair sums, -240 to 210, fits in 2B+1 = 9 signed bits (as in the schematic)
wire signed [2*bw:0] s01 = p0 + p1;
wire signed [2*bw:0] s23 = p2 + p3;

// level 2: both pair sums plus psum_in; all signed, so s01 and s23 are sign-extended to 16 bits
assign out = c + s01 + s23;

endmodule
