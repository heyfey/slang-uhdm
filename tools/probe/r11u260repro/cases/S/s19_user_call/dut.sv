// § shadowedImportTsRefOwner260 (a user function argument)
package rp;
  localparam int OffD = 3;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int OffD = 3;
  function automatic logic [7:0] f(int x);
    return 8'(x);
  endfunction
  always_comb q = a + f(OffD);
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
