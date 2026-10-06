// § elabParamRefSignedTsUnlocated264
module leaf #(parameter int P = 2) (output logic [31:0] o);
  localparam int Q = P;
  localparam int R = Q;
  assign o = R;
endmodule
module mid #(parameter int M = 3) (output logic [31:0] o);
  localparam int N = M;
  leaf #(.P(N)) l(.o(o));
endmodule
module top(output logic [31:0] o, output logic [31:0] p);
  mid m1(.o(o));
  mid #(.M(9)) m2(.o(p));
endmodule
