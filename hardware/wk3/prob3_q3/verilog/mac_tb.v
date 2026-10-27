// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module mac_tb;

parameter bw = 4;
parameter psum_bw = 16;

reg clk = 0;

reg  [4*bw-1:0] a;   // 4 activations packed: x0 = a[3:0], ..., x3 = a[15:12]
reg  [4*bw-1:0] b;   // 4 weights packed:     w0 = b[3:0], ..., w3 = b[15:12]
reg  [psum_bw-1:0] c;

// individual activations and weights, only so they can be viewed one by one in the waveform
wire [bw-1:0] x0 = a[1*bw-1:0*bw];
wire [bw-1:0] x1 = a[2*bw-1:1*bw];
wire [bw-1:0] x2 = a[3*bw-1:2*bw];
wire [bw-1:0] x3 = a[4*bw-1:3*bw];
wire [bw-1:0] w0 = b[1*bw-1:0*bw];
wire [bw-1:0] w1 = b[2*bw-1:1*bw];
wire [bw-1:0] w2 = b[3*bw-1:2*bw];
wire [bw-1:0] w3 = b[4*bw-1:3*bw];
wire [psum_bw-1:0] out;
reg  [psum_bw-1:0] expected_out = 0;

integer w_file ; // file handler
integer w_scan_file ; // file handler

integer x_file ; // file handler
integer x_scan_file ; // file handler

integer x_dec;
integer w_dec;
integer i; 
integer u; 

function [3:0] w_bin ;
  input integer  weight ;
  begin

    if (weight>-1)
     w_bin[3] = 0;
    else begin
     w_bin[3] = 1;
     weight = weight + 8;
    end

    if (weight>3) begin
     w_bin[2] = 1;
     weight = weight - 4;
    end
    else 
     w_bin[2] = 0;

    if (weight>1) begin
     w_bin[1] = 1;
     weight = weight - 2;
    end
    else 
     w_bin[1] = 0;

    if (weight>0) 
     w_bin[0] = 1;
    else 
     w_bin[0] = 0;

  end
endfunction



function [3:0] x_bin;
  input integer activation;
  begin
    if (activation>7) begin
     x_bin[3] = 1;
     activation = activation - 8;
    end
    else
     x_bin[3] = 0;
    if (activation>3) begin
     x_bin[2] = 1;
     activation = activation - 4;
    end
    else
     x_bin[2] = 0;
    if (activation>1) begin
     x_bin[1] = 1;
     activation = activation - 2;
    end
    else
     x_bin[1] = 0;
    if (activation>0)
     x_bin[0] = 1;
    else
     x_bin[0] = 0;
  end
endfunction


// Below function is for verification
function [psum_bw-1:0] mac_predicted;
  input [4*bw-1:0] a;        // 4 packed activations (unsigned)
  input [4*bw-1:0] b;        // 4 packed weights (signed)
  input [psum_bw-1:0] c;
  integer a_int, b_int, c_int, k;
  begin
    c_int = c;
    if (c[psum_bw-1]) c_int = c_int - (1 << psum_bw);
    for (k=0; k<4; k=k+1) begin             // add x_k * w_k for each of the 4 pairs
      a_int = a[k*bw +: bw];
      b_int = b[k*bw +: bw];
      if (b_int[bw-1]) b_int = b_int - (1 << bw);
      c_int = c_int + a_int * b_int;
    end
    mac_predicted = c_int;
  end
endfunction



mac_wrapper #(.bw(bw), .psum_bw(psum_bw)) mac_wrapper_instance (
	.clk(clk), 
        .a(a), 
        .b(b),
        .c(c),
	.out(out)
); 
 

initial begin 

  w_file = $fopen("b_data.txt", "r");  //weight data
  x_file = $fopen("a_data.txt", "r");  //activation

  $dumpfile("mac_tb.vcd");
  $dumpvars(0,mac_tb);
 
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;

  $display("-------------------- Computation start --------------------");
  

  for (i=0; i<5; i=i+1) begin  // 20 entries per data file, 4 per cycle -> 5 cycles

     #1 clk = 1'b1;
     #1 clk = 1'b0;

     for (u=0; u<4; u=u+1) begin  // entries 4i+1 to 4i+4 -> x0..x3 and w0..w3
       w_scan_file = $fscanf(w_file, "%d\n", w_dec);
       x_scan_file = $fscanf(x_file, "%d\n", x_dec);

       a[u*bw +: bw] = x_bin(x_dec); // unsigned number
       b[u*bw +: bw] = w_bin(w_dec); // signed number
     end
     c = expected_out;

     expected_out = mac_predicted(a, b, c);

  end



  #1 clk = 1'b1;
  #1 clk = 1'b0;

  $display("-------------------- Computation completed --------------------");

  #10 $finish;


end

endmodule




