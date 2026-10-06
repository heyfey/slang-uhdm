// § shareDefParamTsOwnNotImport262 (body localparam read in a nested module instantiation's override inside an if-generate)
package rp;
  localparam int K = 2;
endpackage
module leaf #(parameter int W = 1) (input logic [7:0] a, output logic [W-1:0] q);
  assign q = a[W-1:0];
endmodule
module ctrl import rp::*; #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  if (E) begin : g
    leaf #(.W(K)) l (.a(a), .q(q));
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
