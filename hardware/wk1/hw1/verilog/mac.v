// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, A, B, format, acc, clk, reset);

parameter bw = 8;
parameter psum_bw = 16;

input clk;
input acc;
input reset;
input format;

input signed [bw-1:0] A;
input signed [bw-1:0] B;

output signed [psum_bw-1:0] out;

reg signed [psum_bw-1:0] psum_q;
reg signed [bw-1:0] a_q;
reg signed [bw-1:0] b_q;

assign out = psum_q;

// Your code goes here
always @ (posedge clk) begin
    a_q <= A;
    b_q <= B;
    if (reset == 1) begin
        psum_q <= 0;
    end else begin

        case (acc)
            0 : begin
                psum_q <= a_q * b_q;
            end
            1 : begin
                psum_ q <= psum_q + a_q * b_q;
            end
        endcase

    end
end

endmodule
