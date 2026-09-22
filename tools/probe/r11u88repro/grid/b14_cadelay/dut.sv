// v11u83 b14 -- LAW B BREAK: the elab clone copies vpiParent, the span, the
// Lhs and the Rhs.  It does NOT copy a cont_assign's DELAY, its DRIVE
// STRENGTH or vpiNetDeclAssign.  LAW B newly routes struct-param cells into
// that clone, so a cell that pristine SHARED (delay and all) may now lose it.
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
endpackage

interface ifc #(parameter pk::s_t C = '{n: 8'd6, m: 8'd9}) ();
  logic [31:0] d_del;
  logic [31:0] d_str;
  logic [31:0] d_plain;
  assign #5 d_del = C.n;
  assign (strong1, weak0) d_str = C.m;
  assign d_plain = C.n;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.d_del ^ u_if.d_str ^ u_if.d_plain;
endmodule
