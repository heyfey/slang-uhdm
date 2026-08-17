// v7 — the vrgg1 fix's DISCRIMINATOR under stress: every shape where the DEF
// view might already hold a constant for an enum-constant Rhs, so that
// "def constant wins" could over-reach.
//   - iface-dot CA inside a GENERATE scope (both qualified and unqualified)
//   - iface-dot CA inside an INTERFACE body (the "interface def views keep the
//     ref" comment in ModuleEmit)
//   - the same enum member read BOTH qualified and unqualified in one module
//   - an enum member reached through a `import pkg::MEMBER` explicit import
//   - a scoped read of a member of an enum declared in a nested package scope
package p_v7;
  typedef enum logic [1:0] { E_A = 2'b00, E_B = 2'b10 } e_t;
  typedef enum logic [3:0] { H_A = 4'h6 } h_t;
endpackage

interface if_v7;
  logic [1:0] a, b, c, d, e, g0, g1, q0, q1;
  logic [3:0] h;
endinterface

interface drv_v7 (if_v7 vif);
  import p_v7::*;
  assign vif.q0 = E_B;              // F1 iface BODY, unqualified
  assign vif.q1 = p_v7::E_B;        // F2 iface BODY, QUALIFIED
endinterface

module dut_v7 #(parameter int NG = 2) (if_v7 vif);
  import p_v7::*;
  import p_v7::E_A;                 // explicit single-member import
  assign vif.a = E_A;               // F3 unqualified (import *)
  assign vif.b = p_v7::E_A;         // F4 QUALIFIED, same member as F3
  assign vif.c = E_B;               // F5 unqualified
  assign vif.d = p_v7::E_B;         // F6 QUALIFIED, same member as F5
  assign vif.h = p_v7::H_A;         // F7 QUALIFIED HEX
  assign vif.e = H_A[1:0];          // F8 part-select of an enum member
  for (genvar i = 0; i < 2; i++) begin : gb
    if (i == 0) assign vif.g0 = E_B;         // F9  gen-scope, unqualified
    else        assign vif.g1 = p_v7::E_B;   // F10 gen-scope, QUALIFIED
  end
  drv_v7 u_drv (.vif(vif));
endmodule

module v7_vrgg1;
  if_v7 vif();
  dut_v7 #(.NG(2)) u (.vif(vif));
endmodule
