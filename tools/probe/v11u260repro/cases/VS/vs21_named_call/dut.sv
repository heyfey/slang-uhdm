// § shadowedImportTsRefOwner260 (the fold as a named user-call argument and as a $clog2 argument in one statement)
package rp;
  localparam int OffD = 4;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int OffD = 4;
  function automatic logic [7:0] f(int n, logic [7:0] x);
    return x >> n;
  endfunction
  always_comb q = f(.n(OffD), .x(a)) + 8'($clog2(OffD));
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
