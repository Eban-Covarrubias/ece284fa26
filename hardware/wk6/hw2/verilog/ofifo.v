// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
module ofifo (clk, in, out, rd, wr, o_full, reset, o_ready, o_valid);

  parameter col  = 8;
  parameter bw = 4;

  input  clk;
  input  [col-1:0] wr;          // one write enable per column
  input  rd;
  input  reset;
  input  [col*bw-1:0] in;
  output [col*bw-1:0] out;
  output o_full;
  output o_ready;
  output o_valid;

  wire [col-1:0] empty;
  wire [col-1:0] full;
  reg  rd_en;

  genvar i;

  assign o_ready = ~(|full) ;   // room for one more vector: no column FIFO is full
  assign o_full  = |full ;      // at least one column FIFO is full
  assign o_valid = ~(|empty) ;  // a complete vector is ready: every column FIFO holds an entry

  for (i=0; i<col ; i=i+1) begin : col_num
      fifo_depth64 #(.bw(bw)) fifo_instance (
	 .rd_clk(clk),
	 .wr_clk(clk),
	 .rd(rd_en),
	 .wr(wr[i]),
         .o_empty(empty[i]),
         .o_full(full[i]),
	 .in(in[bw*(i+1)-1:bw*i]),
	 .out(out[bw*(i+1)-1:bw*i]),
         .reset(reset));
  end


  always @ (posedge clk) begin
   if (reset) begin
      rd_en <= 0;
   end
   else
      rd_en <= rd;              // read all columns at a time
  end




endmodule
