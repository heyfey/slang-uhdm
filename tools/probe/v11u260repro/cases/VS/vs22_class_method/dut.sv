// § shadowedImportTsRefOwner260 (the fold as an indexed part-select width inside a module-local class method)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q);
  localparam int OffD = 2;
  class k;
    function logic [1:0] f(logic [7:0] x);
      return x[2 +: OffD];
    endfunction
  endclass
  assign q = a[5 +: OffD];
endmodule
module top;
  logic [7:0] a; logic [1:0] q;
  ctrl u (.a(a), .q(q));
endmodule
