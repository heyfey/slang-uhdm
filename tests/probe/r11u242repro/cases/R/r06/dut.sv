// § impArrParamTsOwnRanges242
// The importer at depth 2 inside a generate scope, instantiated twice with different
// parameters; the array indexed by the parameter.
package hp;
  parameter int A [3] = '{10, 20, 30};
endpackage
module leaf import hp::*; #(parameter int K = 0) (input logic [1:0] k, output logic [31:0] o);
  assign o = A[k] + K;
endmodule
module top (input logic [1:0] k, output logic [31:0] o0, output logic [31:0] o1);
  for (genvar g = 0; g < 2; g++) begin : gg
    logic [31:0] t;
    leaf #(.K(g)) u (.k(k), .o(t));
  end
  assign o0 = gg[0].t;
  assign o1 = gg[1].t;
endmodule
