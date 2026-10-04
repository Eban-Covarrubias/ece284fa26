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
wire [psum_bw-1:0] prod_sm;

wire [bw-2:0] a_q_u;
wire [bw-2:0] b_q_u;

reg signed [psum_bw-1:0] psum_q;
reg signed [bw-1:0] a_q;
reg signed [bw-1:0] b_q;

assign out = psum_q;
assign a_q_u = a_q[bw-2:0]; //trim off the sign bit
assign b_q_u = b_q[bw-2:0]; //trim off the sign bit
wire [psum_bw-2: 0] prod_mag;
assign prod_mag =  a_q_u * b_q_u;
assign prod_sm = {a_q[bw-1] ^ b_q[bw-1], prod_mag};

// Your code goes here
always @ (posedge clk) begin
    a_q <= A;
    b_q <= B;
    if (reset == 1) begin
        psum_q <= 0;
    end else begin
        if (format == 0) begin
            case (acc)
                0 : begin
                    psum_q <= a_q * b_q;
                end
                1 : begin
                    psum_q <= psum_q + a_q * b_q;
                end
            endcase
        end else begin
            case (acc)
                0 : begin
                    psum_q <= prod_sm;
                end
                1 : begin
                    if (psum_q[psum_bw-1] == prod_sm[psum_bw-1]) begin
                        psum_q <= {psum_q[psum_bw-1], prod_sm[psum_bw-2:0] + psum_q[psum_bw-2:0]};
                    end else if (psum_q[psum_bw-1] > prod_sm[psum_bw-1]) begin
                        //need to consider magnitudes to compute properly...
                        if (psum_q[psum_bw-2:0] > prod_sm[psum_bw-2:0])
                            psum_q <= {1'b1, psum_q[psum_bw-2:0] - prod_sm[psum_bw-2:0]};
                        else //(psum_q[psum_bw-2:0] <= prod_sm[psum_bw-2:0])
                            psum_q <= {1'b0, prod_sm[psum_bw-2:0] - psum_q[psum_bw-2:0]};
                    end else begin
                        //psum_q is positive, prod sm is negative
                        //need to consider magnitudes to compute properly...
                        if (psum_q[psum_bw-2:0] >= prod_sm[psum_bw-2:0])
                            psum_q <= {1'b0, psum_q[psum_bw-2:0] - prod_sm[psum_bw-2:0]};
                        else //(psum_q[psum_bw-2:0] < prod_sm[psum_bw-2:0])
                            psum_q <= {1'b1, prod_sm[psum_bw-2:0] - psum_q[psum_bw-2:0]};
                    end
                end
            endcase
        end

    end
end

endmodule
