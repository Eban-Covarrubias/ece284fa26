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

reg [bw:0] temp;

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
        temp <= 0;
    end else begin

        if (format == 0) begin
            temp <= a_q + b_q; //default is signed 2's complement i think
        end else begin
            //need to do sign and magnitude system addition
            if (a_q[bw-1] == b_q[bw-1]) begin
                //they are the same sign
                temp <= {a_q[bw-1] , a_q + b_q}
            end
        end


        if (acc == 1) begin
            if 
            psum_q <= psum_q + temp;
        end else begin
            psum_q <= temp;
        end
    end
end

endmodule
