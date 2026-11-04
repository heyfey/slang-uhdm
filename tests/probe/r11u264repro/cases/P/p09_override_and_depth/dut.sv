// § elabParamRefSignedTsUnlocated264
module leaf #(parameter int D = 4) (output logic [7:0] o);
  localparam int B = D;
  localparam int C = B;
  assign o = C;
endmodule
module mid #(parameter int M = 2) (output logic [7:0] o);
  localparam int K = M;
  leaf #(.D(K)) l(.o(o));
endmodule
module top(output logic [7:0] o);
  mid #(.M(9)) m(.o(o));
endmodule
