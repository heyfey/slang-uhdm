// r11v55 VERIFIER arm — THE BLAST RADIUS INSIDE THE PRISTINE ARM.
// § structParamSetter already fired for "the parameter's OWN initializer is a
// pattern, one level deep".  The law now hands that same path a member TYPE
// (`spsMemberTy55`) and runs a restamp + adjustSize over it, so every row the
// pristine arm already served is re-sized.  These are the corpus shapes
// (PackStructField / StructLocalParam / StructParameter: a 1-bit member onto a
// 1- or 2-bit Lhs) plus the widths around them.  Any cell where the law's size
// differs from BOTH pristine and golden is a regression on an equal row.
package p;
  typedef struct packed { logic a; logic b; } tiny_t;
  typedef struct packed { logic [1:0] q; int unsigned n; } mix_t;
endpackage
module dut #(parameter p::tiny_t T = '{a: 1'b1, b: 1'b0},
             parameter p::mix_t  M = '{q: 2'b10, n: 300})
           (output logic       o_a1,      // 1-bit member -> 1-bit Lhs
            output logic [1:0] o_a2,      // 1-bit member -> 2-bit Lhs
            output logic [31:0] o_a32,    // 1-bit member -> 32-bit Lhs
            output logic [1:0] o_q2,      // 2-bit member -> 2-bit Lhs
            output logic       o_q1,      // 2-bit member -> 1-bit Lhs (shrink)
            output logic [7:0] o_n8,      // 32-bit member -> 8-bit Lhs (mask)
            output logic [31:0] o_n32);
  assign o_a1  = T.a;
  assign o_a2  = T.a;
  assign o_a32 = T.a;
  assign o_q2  = M.q;
  assign o_q1  = M.q;
  assign o_n8  = M.n;
  assign o_n32 = M.n;
endmodule
