// r11u83 j3 -- LAW B and the landed Lhs FENCE.  A struct-param member read
// written onto a BIT-SELECT / PART-SELECT / element Lhs: the module-level
// law declines these (§ caStructParamPatternSubst55's plainLhs fence) and so
// must this home.  The whole-name row beside them is the positive control.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage

interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] whole;
  logic [31:0] bitsel;
  logic [31:0] partsel;
  logic [31:0] arr [0:1];
  assign whole     = C.n;
  assign bitsel[0] = C.n;
  assign partsel[3:0] = C.n;
  assign arr[0]    = C.n;
endinterface

module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = u_i.whole ^ u_i.bitsel ^ u_i.partsel ^ u_i.arr[0];
endmodule
