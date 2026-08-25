// r10v84 arm v4 — CONTEXTS THE LAW MUST REFUSE, or must handle.
// A `bind` instantiation, a HIERARCHICAL parameter read in the base slot, a
// parameter declared in an INTERFACE, a specparam, an enum constant, and the
// select as a RANGE bound of a declaration (Reduce::No, MUST STAY).
package cv84;
  parameter int CW = 8;
endpackage

module sinkv84 #(parameter int W = 8) (input logic [W-1:0] a);
endmodule

interface ifc84;
  localparam int IFP = 2;
endinterface

module bindee84;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  localparam int Bd = 2;
endmodule

module bnd84 (input logic [7:0] a);
endmodule

module ctx4_84;
  import cv84::*;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  localparam int Db = 2;

  typedef enum int { EA = 2, EB = 3 } e_t;

  bindee84 u_be ();
  ifc84    u_ifc ();

  // a HIERARCHICAL parameter read in the BASE slot
  sinkv84 #(.W(CW)) c_hier (.a(reg2hw.addr.q[u_be.Bd +: CW]));
  // a parameter declared in an INTERFACE, read hierarchically
  sinkv84 #(.W(CW)) c_ifp  (.a(reg2hw.addr.q[u_ifc.IFP +: CW]));
  // an ENUM CONSTANT in the BASE slot
  sinkv84 #(.W(CW)) c_enum (.a(reg2hw.addr.q[EA +: CW]));
  // the SAME localparam as a DECLARATION range bound (Reduce::No, must stay)
  logic [Db+7:Db] decl4;
  assign decl4 = '0;
  // and as a part_select RIGHT bound inside a hier_path High_conn
  sinkv84 #(.W(2)) c_ps (.a(reg2hw.addr.q[Db+1 : Db]));
endmodule

// a BIND instantiation whose High_conn carries the very same shape
bind bindee84 bnd84 u_bind (.a(reg2hw.addr.q[Bd +: 8]));
