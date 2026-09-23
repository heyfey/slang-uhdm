package pk; parameter int unsigned W = $clog2(4); parameter int S = 2; parameter logic [3:0] L = 2; parameter bit B1 = 1'b1; typedef logic [3:0] n_t; parameter n_t N = 3; parameter byte BY = 2; endpackage
interface bif import pk::*; (input logic s);
  logic [2:0] y [2];
  for (genvar fb = 0; fb < 2; fb++) begin : g
    assign y[fb] = {{W{1'b0}}, s};
  end
endinterface
module top (input logic s, output logic [2:0] o);
  bif b (.s(s));
  assign o = b.y[0];
endmodule
