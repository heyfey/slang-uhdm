// r10earl108 g3 — THE ACTUAL-KIND AXIS.  The FORMAL is fixed at the corpus's
// own `parameter bit R = 0`; only what is WRITTEN at the override varies.
// MEASUREMENT ONLY.  The official uhdm-cmp is the sole judge.
package r108;
  typedef struct packed {
    logic [1:0] a;
    logic [1:0] b;
    logic [1:0] c;
    logic       d;
  } rsp_t;
  typedef struct packed {
    logic [3:0] hi;
    logic [1:0] lo;
  } inner_t;
  typedef struct packed {
    inner_t     n;
    logic [2:0] t;
  } outer_t;

  // named pattern (the corpus form)
  parameter rsp_t RSP = '{a: 2'b01, b: 2'b01, c: 2'b10, d: 1'b0};
  // POSITIONAL pattern
  parameter rsp_t RPOS = '{2'b11, 2'b00, 2'b10, 1'b1};
  // a `default:` FILL
  parameter rsp_t RDEF = '{default: 1'b1};
  // a NESTED struct member
  parameter outer_t RNEST = '{n: '{hi: 4'ha, lo: 2'b01}, t: 3'b101};
  // an UNBASED-UNSIZED member value (r10earl107's own re-type rule)
  parameter rsp_t RUNB = '{a: '1, b: '0, c: 2'b10, d: 1'b1};
  // a plain int package param (a CONTROL: no pattern to substitute)
  parameter int PLAIN = 7;
endpackage

module ch108 #(parameter bit R = 0) (output logic o);
  assign o = R;
endmodule

module g3_src108
  import r108::*;
(
  output logic [10:0] o
);
  // a MODULE-LOCAL struct localparam
  localparam rsp_t LOC = '{a: 2'b10, b: 2'b01, c: 2'b11, d: 1'b0};
  localparam int   K   = 3;

  // a — the corpus shape: a bare, wildcard-imported package struct param
  ch108 #(.R(RSP))    i_a (.o(o[0]));
  // b — the SAME parameter written pkg::-QUALIFIED
  ch108 #(.R(r108::RSP)) i_b (.o(o[1]));
  // c — an assignment pattern written INLINE at the connection
  ch108 #(.R(rsp_t'{a: 2'b01, b: 2'b01, c: 2'b10, d: 1'b0})) i_c (.o(o[2]));
  // d — a MODULE-LOCAL struct localparam
  ch108 #(.R(LOC))    i_d (.o(o[3]));
  // e — an INT LITERAL actual (control)
  ch108 #(.R(1))      i_e (.o(o[4]));
  // f — an EXPRESSION actual (control)
  ch108 #(.R(K + 1))  i_f (.o(o[5]));
  // g — a POSITIONAL pattern in the referenced parameter
  ch108 #(.R(RPOS))   i_g (.o(o[6]));
  // h — a `default:` FILL in the referenced parameter
  ch108 #(.R(RDEF))   i_h (.o(o[7]));
  // i — a NESTED struct member in the referenced parameter
  ch108 #(.R(RNEST))  i_i (.o(o[8]));
  // j — UNBASED-UNSIZED member values in the referenced parameter
  ch108 #(.R(RUNB))   i_j (.o(o[9]));
  // k — a plain INT package param actual (control)
  ch108 #(.R(PLAIN))  i_k (.o(o[10]));
endmodule
