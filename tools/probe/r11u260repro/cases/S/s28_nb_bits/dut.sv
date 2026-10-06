// § shadowedImportTsRefOwner260 (a $bits-free unary operand in a named block)
package rp;
  localparam int OffD = 3;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int OffD = 3;
  always_comb begin : nb
    q = a << OffD;
  end
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
