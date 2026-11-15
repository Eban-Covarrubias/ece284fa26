// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, valid);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  input  [row*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  output [col-1:0] valid;

  reg    [2*row-1:0] inst_w_temp;            // instruction shift register, 2 bits per row
  wire   [psum_bw*col*(row+1)-1:0] temp;     // psum chain: slot 0 = array in_n, slot i = out_s of row i
  wire   [row*col-1:0] valid_temp;           // valid vector of every row

  assign temp[psum_bw*col-1:0] = in_n;
  assign out_s = temp[psum_bw*col*(row+1)-1:psum_bw*col*row];   // out_s of the last row
  assign valid = valid_temp[row*col-1:row*col-col];             // valid of the last row only

  genvar i;
  for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw), .col(col)) mac_row_instance (
         .clk(clk),
         .reset(reset),
         .in_w(in_w[bw*i-1:bw*(i-1)]),
         .inst_w(inst_w_temp[2*i-1:2*(i-1)]),
         .in_n(temp[psum_bw*col*i-1:psum_bw*col*(i-1)]),
         .out_s(temp[psum_bw*col*(i+1)-1:psum_bw*col*i]),
         .valid(valid_temp[col*i-1:col*(i-1)]));
  end

  integer j;
  always @ (posedge clk) begin


   // inst_w flows to row0 to row7
    if (reset == 1)
      inst_w_temp <= 0;
    else begin
      inst_w_temp[1:0] <= inst_w;                               // first row: one register stage
      for (j=1; j < row; j=j+1)
        inst_w_temp[2*j +: 2] <= inst_w_temp[2*(j-1) +: 2];   // each row one cycle after the row above
    end

  end



endmodule
