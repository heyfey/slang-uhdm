// r10v87 arm va8 — an ASSIGNMENT-PATTERN override on a struct formal that
// collides with a wildcard-imported struct parameter.  This is the branch of
// NetlistElaboration::elab_parameters_ that clones the module row EARLY
// (NetlistElaboration.cpp:258-320) instead of falling through to the
// `MakeParam_assign` at line 325 — it stamps from the SAME name set, so the
// law must hold there too.
package pz8;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } cfg_t;
  localparam cfg_t YA = '{a: 8'd1,  b: 8'd2};
  localparam cfg_t YB = '{a: 8'd3,  b: 8'd4};
endpackage

module zleaf #(parameter pz8::cfg_t YA = '{a: 8'd9, b: 8'd9})
              (output logic [7:0] o);
  import pz8::*;
  assign o = YA.a + YA.b + YB.a;
endmodule

module top87 (output logic [7:0] o1, o2);
  zleaf #(.YA('{a: 8'd5, b: 8'd6})) u_p (.o(o1));
  zleaf                             u_d (.o(o2));
endmodule
