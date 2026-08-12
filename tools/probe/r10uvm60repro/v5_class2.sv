// VERIFIER ARM v5 — DECODE arm v2's over-fire: is the discriminator CLASS-NESS,
// or did Surelog's evaluator simply GIVE UP on the whole chain because a class
// static method call is not reducible?
//   caller  IS the cont-assign rhs; it holds BOTH a constant actual of its own
//           (g60(1)) AND the call into the class method.
//   caller2 IS a second cont-assign rhs with the SAME constant actual and NO
//           class call at all — the control.
// If golden stamps in caller but not in c62::sm  -> CLASS-NESS is the gate.
// If golden is bare in caller too (while caller2 stamps) -> an unreducible
// callee POISONS the whole chain, and the law is "the body was actually
// REDUCED", not "the body is reachable from a seed".
package p65;
   function automatic bit [3:0] h65(bit [3:0] v);
      return v;
   endfunction
   class c65;
      static function bit [3:0] sm(bit [3:0] x);
         return x + h65(1);
      endfunction
   endclass
endpackage

module v5_class2(input logic [3:0] i, output logic [3:0] o, output logic [3:0] o2);
   import p65::*;

   function automatic logic [3:0] g65(logic [3:0] v);
      return v;
   endfunction

   function automatic logic [3:0] caller(logic [3:0] x);
      return c65::sm(x) + g65(1);      // constant actual BESIDE the class call
   endfunction

   function automatic logic [3:0] caller2(logic [3:0] x);
      return x + g65(1);               // control: no class call anywhere
   endfunction

   assign o  = caller(i);
   assign o2 = caller2(i);
endmodule
