// r11u83 j2 -- LAW B across TWO elaborated copies with DIFFERENT
// parameterizations: each view's folded constant is its own instance's value,
// and a MODULE twin beside them is the in-arm control for the landed
// module-level home.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t L1 = '{n: 6};
  localparam cfg_t L2 = '{n: 9};
endpackage

interface ifc #(parameter p::cfg_t C = p::L1) ();
  logic [31:0] i_top;
  assign i_top = C.n;
endinterface

module mtwin #(parameter p::cfg_t C = p::L1) (output logic [31:0] q);
  assign q = C.n;
endmodule

module dut (output logic [31:0] o1, o2, o3);
  ifc          u_a ();
  ifc #(p::L2) u_b ();
  mtwin        u_m (.q(o3));
  assign o1 = u_a.i_top;
  assign o2 = u_b.i_top;
endmodule
