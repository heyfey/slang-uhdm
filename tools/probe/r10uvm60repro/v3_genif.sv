// VERIFIER ARM v3 — the GENERATE-IF CONDITION cell, ISOLATED.
// The landed seed set is {cont-assign rhs, param initialiser}.  A generate-if
// CONDITION is an elaboration-time constant expression Surelog also reduces, so
// the body it calls IS evaluated — and golden stamps the constant actual inside
// it.  This arm holds nothing else, so the cmp verdict is about this cell alone.
module v3_genif(input logic [3:0] inp, output logic [3:0] o);
   function automatic logic [3:0] g60(logic [3:0] v);
      return v;
   endfunction
   function automatic logic [3:0] w1(logic [3:0] x);
      return x + g60(1);
   endfunction
   if (w1(4'd1) > 0) begin : gblk
      logic dummy;
   end
   assign o = inp;
endmodule
