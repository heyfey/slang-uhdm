// § pkgQualBoundSpanQualifier192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module top (input logic [31:0] x, output logic [31:0] y [2], output logic [31:0] w);
  for (genvar i = 0; i < 2; i++) begin : g
    always_comb y[i] = x[p::S:0];
  end
  wire [31:0] n = x[p::S:0];
  assign w = n;
endmodule
