// v3 — the FOLD-FAMILY positions the five prior laws mapped, each reading an
// enum member THROUGH a constant-condition ternary (the L2 shape) and, where
// the position allows it, onto an INTERFACE MEMBER (the L1 shape):
// cont-assign, net-decl-assign, gen-scope, UNTAKEN branch, member-LHS, cast,
// replication, initializer.
package p_v3;
  typedef enum logic [1:0] { E_A = 2'b00, E_B = 2'b10 } e_t;
endpackage

interface if_v3;
  logic [1:0] ca, nd, gs, ub, ml, cs, rp, ini, tern;
  logic [7:0] wide;
endinterface

module dut_v3 #(parameter bit BZ = 1'b0, parameter bit B1 = 1'b1) (if_v3 vif);
  import p_v3::*;
  typedef struct packed { logic [1:0] m; logic [1:0] n; } st_t;

  // C1 cont-assign, bare enum const onto iface member (the shipped law)
  assign vif.ca = E_A;
  // C2 cont-assign, enum const through a TERNARY onto iface member
  assign vif.tern = (B1) ? E_B : E_A;
  // C3 net-decl-assign, bare enum const
  wire [1:0] w_nd = E_B;
  assign vif.nd = w_nd;
  // C4 net-decl-assign, enum const through a ternary
  wire [1:0] w_nd2 = (BZ) ? E_B : E_A;
  // C5 UNTAKEN branch of a ternary must NOT be folded/read
  wire [1:0] w_ub = (BZ) ? E_B : E_A;
  assign vif.ub = w_ub;
  // C6 member-LHS (struct member) with enum const
  st_t s1;
  assign s1.m = E_B;
  assign s1.n = (B1) ? E_B : E_A;
  assign vif.ml = s1.m;
  // C7 CAST of an enum const, and of a ternary over enum consts
  assign vif.cs = 2'(E_B);
  wire [1:0] w_cs = 2'((B1) ? E_B : E_A);
  // C8 REPLICATION over an enum const / ternary
  assign vif.wide = {4{E_A}};
  wire [7:0] w_rp = {4{(B1) ? E_B : E_A}};
  // C9 variable INITIALIZER with an enum const / ternary
  logic [1:0] v_i  = E_B;
  logic [1:0] v_i2 = (BZ) ? E_B : E_A;
  assign vif.ini = v_i;
  // C10 GEN-SCOPE: iface-member cont-assign and localparam inside a genblock
  for (genvar g = 0; g < 2; g++) begin : gb
    localparam e_t GP = (B1) ? E_B : E_A;
    wire [1:0] gw = GP;
  end
  assign vif.gs = gb[0].gw;
  // C11 UNTAKEN generate branch — nothing inside may be read
  if (BZ) begin : gtaken
    localparam e_t GQ = E_B;
    wire [1:0] gqw = GQ;
  end else begin : gelse
    localparam e_t GR = (B1) ? E_B : E_A;
    wire [1:0] grw = GR;
  end
  assign vif.rp = w_rp[1:0];
endmodule

module v3_vrgg1;
  if_v3 vif();
  dut_v3 #(.BZ(1'b0), .B1(1'b1)) u (.vif(vif));
endmodule
