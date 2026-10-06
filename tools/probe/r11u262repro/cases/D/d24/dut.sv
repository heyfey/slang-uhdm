// § shareDefParamTsOwnNotImport262 (body localparam read as an indexed part-select width in an if-generate assignment: v11u260 VS/vs15)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  if (E) begin : g
    assign q = a[4 +: K];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
