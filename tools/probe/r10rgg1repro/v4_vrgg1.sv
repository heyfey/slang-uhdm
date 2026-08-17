// v4 — L1 boundary: interface-member Lhs shapes the new arm must NOT
// over-reach.  Deeper dotted paths, MODPORT ports, nested interface, 4-state
// enum member, a plain (non-interface) instance base, and a struct-typed
// interface member.
package p_v4;
  typedef enum logic [1:0] { E_A = 2'b00, E_B = 2'b10 } e_t;
  typedef enum logic [1:0] { X_A = 2'bx1 } x_t;
endpackage

interface inner_v4;
  logic [1:0] q;
endinterface

interface if_v4;
  logic [1:0] a, b, c, d, e;
  inner_v4 sub();
  modport mp (output a, output b, output c, output d, output e);
endinterface

module sub_v4 (if_v4.mp m);
  import p_v4::*;
  assign m.a = E_B;                 // D1 modport-port dotted Lhs, enum const
endmodule

module dut_v4 (if_v4 vif);
  import p_v4::*;
  assign vif.sub.q = E_B;           // D2 TWO-level dotted path
  assign vif.b     = X_A;           // D3 4-state enum member (2'bx1)
  assign vif.c     = e_t'(2'b10);   // D4 enum CAST of a literal, not a ref
  assign vif.d     = E_A;           // D5 the plain shipped shape (control)
  sub_v4 u_sub (.m(vif));
endmodule

module other_v4;
  import p_v4::*;
  logic [1:0] z;
  assign z = E_B;                   // D6 plain signal, no interface at all
endmodule

module v4_vrgg1;
  if_v4 vif();
  dut_v4 u (.vif(vif));
  other_v4 o ();
endmodule
