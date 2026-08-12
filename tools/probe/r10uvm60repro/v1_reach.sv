// VERIFIER ARM v1 — EMPTY-CELL HUNT on the *reachability* axis.
// The landed law says a CONSTANT actual inside a subroutine body is stamped
// with the formal's typespec ONLY when Surelog's evaluator RAN that body, and
// models that set as the transitive closure of exactly TWO seeds:
//    (a) callee of a continuous-assign RHS      (b) callee of a param init
// b6_reached.sv tested a/b + always_comb + initial.  It NEVER tested the other
// CONSTANT-EXPRESSION contexts a body can be reached from, each of which
// Surelog's evaluator also reduces.  If golden STAMPS in any row below, the
// landed conjunct UNDER-FIRES there (pristine stamped; patched will not).
module v1_reach(input logic [3:0] inp, output logic [3:0] o);

   function automatic logic [3:0] g60(logic [3:0] v);
      return v;
   endfunction

   // one body per row, all identical, only the REACH differs
   function automatic logic [3:0] w1(logic [3:0] x); return x + g60(1); endfunction
   function automatic logic [3:0] w2(logic [3:0] x); return x + g60(1); endfunction
   function automatic logic [3:0] w3(logic [3:0] x); return x + g60(1); endfunction
   function automatic logic [3:0] w4(logic [3:0] x); return x + g60(1); endfunction
   function automatic logic [3:0] w5(logic [3:0] x); return x + g60(1); endfunction
   function automatic logic [3:0] w6(logic [3:0] x); return x + g60(1); endfunction

   // R_GENIF — body reached from a GENERATE-IF condition (constant expr)
   if (w1(4'd1) > 0) begin : gblk
      logic dummy;
   end

   // R_VARINIT — body reached from a module-level VARIABLE initialiser
   logic [3:0] v2 = w2(4'd1);

   // R_DIM — body reached from a PACKED DIMENSION range
   logic [w3(4'd1):0] v3;

   // R_GENPARAM — body reached from a localparam INSIDE a generate block
   if (1) begin : gblk2
      localparam logic [3:0] GP = w5(4'd1);
      logic [3:0] gv = GP;
   end

   // R_CASTSZ — body reached from a CAST size
   logic [7:0] v6 = (w6(4'd1) + 8'd1);

   // R_CAOP — body reached as an OPERAND of a continuous assign (not the whole
   // rhs): the seed requires the call to BE the rhs.
   assign o = w4(inp) + v2 + v3[1:0] + v6[3:0];
endmodule
