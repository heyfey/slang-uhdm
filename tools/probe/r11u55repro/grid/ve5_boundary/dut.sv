// r11u55 ROAD E arm — THE BOUNDARY.  The honest producer predicate is "the Rhs
// reduces to a constant", but our emitter's share decision already has thirteen
// predicates and ~40 corpus directories read a dotted name on a cont_assign.
// These cells are the ones a widened predicate could take over WRONGLY: every
// one of them must keep whatever the pristine binary does today.
//   o_var   — a struct VARIABLE's field (NOT a parameter): never constant
//   o_ifc   — an INTERFACE signal read through a dotted name
//   o_idx   — a field of an unpacked-array parameter ELEMENT (AP[0].n)
//   o_ridx  — a field read under a NON-constant index (AP[a_i].n)
//   o_deep  — a field of a field of a field (three levels)
//   o_arrm  — a packed-array member of a struct parameter (CFG.v)
//   o_selm  — a BIT-SELECT of a struct-parameter member (CFG.n[1])
// The interface cell needs a real top: our binary REJECTS a top-level module
// with an unconnected interface port (rc=3), so the arm wraps `dut`.
package p;
  typedef struct packed { int unsigned n; logic [3:0] v; } inner_t;
  typedef struct packed { inner_t a; inner_t b; } mid_t;
  typedef struct packed { mid_t m; int unsigned k; } outer_t;
  localparam inner_t IL = '{n: 3, v: 4'hA};
  localparam outer_t OL = '{m: '{a: '{n: 5, v: 4'h5}, b: '{n: 6, v: 4'h6}}, k: 9};
  typedef inner_t iarr_t [2];
  localparam iarr_t AL = '{'{n: 11, v: 4'h1}, '{n: 12, v: 4'h2}};
endpackage
interface ifc;
  logic [31:0] w;
  modport mp (input w);
endinterface
module dut #(parameter p::inner_t CFG = p::IL,
             parameter p::outer_t OC  = p::OL,
             parameter p::iarr_t  AP  = p::AL)
           (input logic [31:0] a_i, ifc.mp ii,
            output logic [31:0] o_var,
            output logic [31:0] o_ifc, output logic [31:0] o_idx,
            output logic [31:0] o_ridx, output logic [31:0] o_deep,
            output logic [31:0] o_arrm, output logic [31:0] o_selm);
  p::inner_t sv;
  assign sv     = '{n: a_i, v: 4'h0};
  assign o_var  = sv.n;        // struct VARIABLE field — never constant
  assign o_ifc  = ii.w;        // interface signal through a dotted name
  assign o_idx  = AP[0].n;     // field of an unpacked-array param ELEMENT
  assign o_ridx = AP[a_i].n;   // field under a NON-constant index
  assign o_deep = OC.m.a.n;    // THREE-level field read
  assign o_arrm = CFG.v;       // packed-array member of a struct parameter
  assign o_selm = CFG.n[1];    // bit-select OF a struct-parameter member
endmodule
module top (input logic [31:0] a_i,
            output logic [31:0] o_var, output logic [31:0] o_ifc,
            output logic [31:0] o_idx, output logic [31:0] o_ridx,
            output logic [31:0] o_deep, output logic [31:0] o_arrm,
            output logic [31:0] o_selm);
  ifc ii();
  dut u (.a_i(a_i), .ii(ii.mp), .o_var(o_var), .o_ifc(o_ifc), .o_idx(o_idx),
         .o_ridx(o_ridx), .o_deep(o_deep), .o_arrm(o_arrm), .o_selm(o_selm));
endmodule
