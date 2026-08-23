// r10vearl74 adversarial grid A — NAME COLLISION.
// The design-final pass of § dimBoundInheritsParamEnc74 resolves the sizing
// parameter BY NAME, walking the bound's VpiParent chain OUTWARD.  Every
// module here sizes a dimension with a parameter that has NO param_assign in
// the declaring instance's own scope (a package parameter), while an OUTER
// scope of the instance chain carries a param_assign of the SAME NAME with the
// OTHER encoding and the SAME VALUE.  Golden must keep the package's encoding.
package vpk74;
  localparam int PM = 4 * 2;   // multiplication -> INT: on golden
  localparam int PA = 4 + 4;   // addition       -> UINT: on golden
endpackage

// -- qualified spelling, no local shadow anywhere in the child -------------
module vq74 ();
  logic [3:0] q_pm [vpk74::PM];
  logic [3:0] q_pa [vpk74::PA];
endmodule

// -- wildcard-imported spelling -------------------------------------------
module vw74 ();
  import vpk74::*;
  logic [3:0] w_pm [PM];
  logic [3:0] w_pa [PA];
endmodule

// -- one more hop between the child and the colliding scope ---------------
module vmid74 ();
  vq74 u_q ();
  vw74 u_w ();
endmodule

// -- THE TRAP: the parent instance carries PM and PA with the OTHER tag ----
module vtrap74 ();
  localparam int PM = 4 + 4;   // UINT: on golden, value 8 (package PM is INT:8)
  localparam int PA = 4 * 2;   // INT:  on golden, value 8 (package PA is UINT:8)
  logic [3:0] t_pm [PM];
  logic [3:0] t_pa [PA];
  vq74   u_q   ();
  vw74   u_w   ();
  vmid74 u_mid ();
endmodule

// -- a gen-scope collision on the way out ---------------------------------
module vgtrap74 ();
  localparam int PM = 4 * 2;
  for (genvar gi = 0; gi < 1; gi++) begin : gblk
    localparam int PA = 4 * 2;   // INT:8, shadows the package's UINT:8 name
    vq74 u_q ();
    vw74 u_w ();
    logic [3:0] gt_pa [PA];
  end
endmodule

// -- the SAME children with NO collision above them (the control) ----------
module vctl74 ();
  vq74   u_q   ();
  vw74   u_w   ();
  vmid74 u_mid ();
endmodule

module vtop74 ();
  vtrap74  u_trap  ();
  vgtrap74 u_gtrap ();
  vctl74   u_ctl   ();
endmodule
