// § pkgQualBoundSpanQualifier192
package q;
  parameter int unsigned S = $clog2(16);
endpackage
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2);
  always_comb begin : blk
    logic [31:0] t;
    t = x[q::S:0];
    y1 = t;
  end
  initial y2 = x[q::S:0];
endmodule
