// v2 — NET-array port actual, expression ZOO (the ExprEmit genvarConnFold arm).
module nleaf (input logic p);
  wire w; assign w = p;
endmodule
module top #(parameter int P = 5, parameter int Q = 3) (input logic [63:0] arr);
  genvar i, j;
  for (i = 0; i < 2; ++i) begin : g
    nleaf a00 (.p (arr[i]));
    nleaf a01 (.p (arr[i+1]));
    nleaf a02 (.p (arr[1+i]));
    nleaf a03 (.p (arr[3*i+2]));
    nleaf a04 (.p (arr[2+3*i]));
    nleaf a05 (.p (arr[i-0]));
    nleaf a06 (.p (arr[8-i]));
    nleaf a07 (.p (arr[(i+1)]));
    nleaf a08 (.p (arr[i*2]));
    nleaf a10 (.p (arr[i/1]));
    nleaf a11 (.p (arr[i%2]));
    nleaf a12 (.p (arr[i<<1]));
    nleaf a13 (.p (arr[i>>1]));
    nleaf a14 (.p (arr[i&1]));
    nleaf a15 (.p (arr[i|8]));
    nleaf a16 (.p (arr[i^4]));
    nleaf a17 (.p (arr[P+i]));
    nleaf a19 (.p (arr[P*i]));
    nleaf a21 (.p (arr[P]));
    nleaf a22 (.p (arr[7]));
    nleaf a23 (.p (arr[P+Q]));
    nleaf a24 (.p (arr[i ? 3 : 4]));
    nleaf a25 (.p (arr[2**i]));
    nleaf a26 (.p (arr[3'd2+i]));
    nleaf a27 (.p (arr[3'h2+i]));
    nleaf a28 (.p (arr[3'b010+i]));
    nleaf a30 (.p (arr[i+2+3]));
    nleaf a31 (.p (arr[(2+3)*i]));
    for (j = 0; j < 2; ++j) begin : h
      nleaf b00 (.p (arr[i+j]));
      nleaf b01 (.p (arr[1+2*i+j]));
      nleaf b02 (.p (arr[i*4+j*2+1]));
    end
  end
endmodule
