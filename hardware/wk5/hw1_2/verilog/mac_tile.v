// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
output [bw-1:0] out_e;
input  [1:0] inst_w;
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;

reg [1:0] inst_q;           // instruction latch, forwarded to the east PE
reg [bw-1:0] a_q;           // activation (or weight being loaded), forwarded to the east PE
reg [bw-1:0] b_q;           // stationary weight
reg [psum_bw-1:0] c_q;      // psum from the north PE
reg load_ready_q;           // 1 until this PE has loaded its weight

wire [psum_bw-1:0] mac_out; // a_q * b_q + c_q

assign out_e  = a_q;
assign inst_e = inst_q;
assign out_s  = mac_out;

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q),
        .b(b_q),
        .c(c_q),
	.out(mac_out)
);

always @ (posedge clk) begin
  if (reset == 1) begin
    inst_q       <= 2'b00;
    load_ready_q <= 1'b1;
    a_q          <= 0;
    b_q          <= 0;
    c_q          <= 0;
  end
  else begin
    inst_q[1] <= inst_w[1];             // execute: always accepted

    if (inst_w[0] | inst_w[1])          // kernel load or execute: take the new value from the west
      a_q <= in_w;

    if (inst_w[0] & load_ready_q) begin // first kernel-load cycle: keep this value as the weight
      b_q          <= in_w;
      load_ready_q <= 1'b0;
    end

    if (load_ready_q == 0)              // forward kernel load only after this PE has its weight
      inst_q[0] <= inst_w[0];

    c_q <= in_n;                        // psum from the north, every cycle
  end
end

endmodule
