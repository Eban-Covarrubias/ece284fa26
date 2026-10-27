// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
module mac_wrapper (clk, out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out;
input  [4*bw-1:0] a;      // 4 activations packed: x0 = a[3:0], ..., x3 = a[15:12]
input  [4*bw-1:0] b;      // 4 weights packed:     w0 = b[3:0], ..., w3 = b[15:12]
input  [psum_bw-1:0] c;
input  clk;

reg    [4*bw-1:0] a_q;
reg    [4*bw-1:0] b_q;
reg    [psum_bw-1:0] c_q;

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q),
        .b(b_q),
        .c(c_q),
	.out(out)
);

// all 4 pairs and psum_in are registered on the same edge, no extra pipeline stage
always @ (posedge clk) begin
        b_q  <= b;
        a_q  <= a;
        c_q  <= c;
end

endmodule
