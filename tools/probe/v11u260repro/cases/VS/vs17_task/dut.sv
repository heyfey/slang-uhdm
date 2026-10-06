// § shadowedImportTsRefOwner260 (a module task's part-select bound, called from an always block)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [2:0] q);
  localparam int OffD = 2;
  task automatic t(input logic [7:0] x, output logic [2:0] y);
    y = x[OffD:0];
  endtask
  always_comb t(a, q);
endmodule
module top;
  logic [7:0] a; logic [2:0] q;
  ctrl u (.a(a), .q(q));
endmodule
