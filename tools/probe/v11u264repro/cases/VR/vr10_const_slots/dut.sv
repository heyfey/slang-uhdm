// § elabParamRefSignedTsUnlocated264
module sub #(parameter int W = 4) (input logic [15:0] i, output logic [15:0] o, output logic [7:0] q);
  localparam int B = W;
  localparam int C = B;
  logic [C-1:0] r;
  logic [7:0] arr [B];
  assign r = {C{1'b1}};
  assign o = {i[B +: 4], i[C -: 4], i[B-1:0], r};
  assign q = arr[0] + $bits(r) + C;
endmodule
module child #(parameter int K = 1) (output logic [7:0] o);
  assign o = K;
endmodule
module top(input logic [15:0] i, output logic [15:0] o, output logic [7:0] q, output logic [7:0] z);
  sub u(.i(i), .o(o), .q(q));
  localparam int T = 3;
  localparam int T2 = T;
  child #(.K(T2)) c(.o(z));
endmodule
