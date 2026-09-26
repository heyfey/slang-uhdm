// § rangeHierPathNoFullName168 § structParamBoundAtPatternLeaf168
package p;
  typedef struct packed { int unsigned C; logic Z; } c_t;
  typedef struct packed { c_t B; logic Y; } b_t;
  typedef struct packed { b_t A; int unsigned X; } cfg_t;
  localparam cfg_t CFG_DEF = '{A: '{B: '{C: 2, Z: 1'b0}, Y: 1'b1}, X: 7};
endpackage
interface bus_if #(parameter p::cfg_t CFG = p::CFG_DEF);
  wire w [0:CFG.A.B.C];
  assign w[0] = 1'b1;
endinterface
module top (output logic o);
  bus_if b ();
  assign o = b.w[1];
endmodule
