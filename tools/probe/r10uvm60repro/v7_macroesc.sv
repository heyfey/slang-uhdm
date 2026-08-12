// VERIFIER ARM v7 — the MACRO axes the grid did not build, plus the two token
// shapes the standing rule demands whenever a gate might read names or raw
// text: ESCAPED IDENTIFIERS and `` token pasting.
//   M1 nested macro, TWO levels, literal supplied by the OUTER invocation
//   M2 macro INVOCATION whose ARGUMENTS span a line break (residue R1's shape)
//   M3 the callee name built by `` PASTING, so the call's identifier never
//      appears literally in the source text
//   M4 an ESCAPED identifier for both the callee and the formal
// The landed gate is a SYMBOL-POINTER membership test and reads no name and no
// raw text, so the prediction is: all four cells behave exactly like the plain
// call, and only line/column fields may differ.
`define lit60 1
`define inner60(F, A) F(A)
`define outer60(F) `inner60(F, `lit60)
`define call60(P) P``60(1)

module v7_macroesc(input logic [3:0] inp, output logic [3:0] o);

   function automatic logic [3:0] g60(logic [3:0] v);
      return v;
   endfunction

   function automatic logic [3:0] pfx60(logic [3:0] v);
      return v;
   endfunction

   function automatic logic [3:0] \esc-fn (logic [3:0] \esc-arg );
      return \esc-arg ;
   endfunction

   function automatic logic [3:0] m1(logic [3:0] x);
      return x + `outer60(g60);                 // M1 nested macro
   endfunction

   function automatic logic [3:0] m2(logic [3:0] x);
      return x + g60(
                     1);                        // M2 argument on the next line
   endfunction

   function automatic logic [3:0] m3(logic [3:0] x);
      return x + `call60(pfx);                  // M3 name built by ``
   endfunction

   function automatic logic [3:0] m4(logic [3:0] x);
      return x + \esc-fn (1);                   // M4 escaped identifiers
   endfunction

   // every body above is reached from an always_comb: NOT evaluated, so the
   // landed law predicts BARE + size 64 in all four.
   logic [3:0] a1, a2, a3, a4;
   always_comb begin
      a1 = m1(inp); a2 = m2(inp); a3 = m3(inp); a4 = m4(inp);
   end
   assign o = a1 ^ a2 ^ a3 ^ a4;
endmodule
