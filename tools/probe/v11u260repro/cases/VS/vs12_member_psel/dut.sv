// § shadowedImportTsRefOwner260 (a struct member's part-select bound)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [2:0] q);
  localparam int OffD = 2;
  typedef struct packed { logic [7:0] f; } s_t;
  s_t s;
  assign s.f = a;
  assign q = s.f[OffD:0];
endmodule
module top;
  logic [7:0] a; logic [2:0] q;
  ctrl u (.a(a), .q(q));
endmodule
