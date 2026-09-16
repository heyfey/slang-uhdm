// v11u49 arm v5 — LAW A x LAW B: an UNPACKED package struct param whose only
// reader is a member select written in a package FUNCTION BODY (no p:: anywhere).
package p;
  typedef struct { logic [7:0] CTL; logic [7:0] DAT; } ub_t;
  localparam ub_t UFUN = '{CTL:8'd1, DAT:8'd2};   // selected in a package function
  localparam ub_t UPAR = '{CTL:8'd3, DAT:8'd4};   // selected in a package param decl
  localparam ub_t UNON = '{CTL:8'd5, DAT:8'd6};   // never selected
  localparam int USE = UPAR.DAT;
  function automatic int f(); return UFUN.DAT; endfunction
endpackage
module v5 import p::*; (output logic [31:0] o);
  assign o = UNON.CTL + USE + f();
endmodule
