// § shareDefParamTsOwnNotImport262 (two instances: one overriding the header parameter, one not; an if-generate reads a different name)
package rp;
  parameter int K = 2;
endpackage
module ctrl import rp::*; #(parameter int K = 2, parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q);
  if (E) begin : g
    assign q = a[1:0];
  end
  logic [K-1:0] t;
  assign t = a[K-1:0];
endmodule
module top(input logic [7:0] a, output logic [1:0] q, output logic [1:0] r);
  ctrl #(.K(3)) u (.a(a), .q(q));
  ctrl v (.a(a), .q(r));
endmodule
