// § shadowedImportTsRefOwner260 (a module function's indexed part-select width)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q);
  localparam int OffD = 2;
  function automatic logic [1:0] f(logic [7:0] x);
    return x[1 +: OffD];
  endfunction
  assign q = f(a);
endmodule
module top;
  logic [7:0] a; logic [1:0] q;
  ctrl u (.a(a), .q(q));
endmodule
