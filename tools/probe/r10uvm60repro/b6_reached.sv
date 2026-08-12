// b6_reached — AXIS 5, THE DISCRIMINATOR ARM.  const_fold_func (uhdm2rtlil) is
// the ONE corpus cell where golden DOES stamp a formal typespec on a CONSTANT
// actual of a call inside a SUBROUTINE BODY: `help_mul = inp * loop(2);`, and
// `help_mul` is called as the DIRECT RHS of a CONTINUOUS ASSIGNMENT.  So the
// axis is not the scope but WHETHER SURELOG'S EVALUATOR DESCENDED INTO THE
// BODY.  Every row below calls `g60(1)` (bare `1` on a `bit [3:0]` formal) from
// a function body; only the way that body is REACHED changes:
//   R1 body reached as a CONTINUOUS-ASSIGN RHS        -> predict STAMPED
//   R2 body reached from an always_comb               -> predict BARE
//   R3 body reached from an initial block             -> predict BARE
//   R4 body reached from a LOCALPARAM initialiser     -> predict STAMPED
//   R5 body reached from a CA RHS, TWO levels deep    -> ?
//   R6 CLASS METHOD reached as a CA RHS               -> ? (the UVM head's
//      scope, reached the ONE way that stamps elsewhere)
module b6_reached(input logic [3:0] inp, output logic [3:0] o1, o2, o3, o5, o6);

   function automatic logic [3:0] g60(logic [3:0] v);
      return v;
   endfunction

   function automatic logic [3:0] r1_ca(logic [3:0] x);
      return x + g60(1);
   endfunction

   function automatic logic [3:0] r2_ac(logic [3:0] x);
      return x + g60(1);
   endfunction

   function automatic logic [3:0] r3_init(logic [3:0] x);
      return x + g60(1);
   endfunction

   function automatic logic [3:0] r4_param(logic [3:0] x);
      return x + g60(1);
   endfunction

   function automatic logic [3:0] r5_inner(logic [3:0] x);
      return x + g60(1);
   endfunction

   function automatic logic [3:0] r5_outer(logic [3:0] x);
      return r5_inner(x);
   endfunction

   class c66;
      function logic [3:0] r6_method(logic [3:0] x);
         return x + g60(1);
      endfunction
   endclass

   c66 h = new();

   localparam logic [3:0] R4 = r4_param(4'd2);   // R4 — param initialiser

   logic [3:0] r2v;
   always_comb r2v = r2_ac(inp);                 // R2 — always_comb

   logic [3:0] r3v;
   initial r3v = r3_init(inp);                   // R3 — initial

   assign o1 = r1_ca(inp);                       // R1 — CA rhs
   assign o2 = r2v;
   assign o3 = r3v;
   assign o5 = r5_outer(inp);                    // R5 — two levels under a CA
   // R6 — a class method CANNOT be a continuous-assign RHS (slang:
   // -Wdynamic-non-procedural, "cannot refer to a member of a dynamic type
   // outside of a procedural context"), so the ONE way golden's evaluator
   // descends into a body is UNREACHABLE for a class method BY THE LANGUAGE.
   // The cell is therefore EMPTY, not untested: it cannot exist.
   assign o6 = '0;
endmodule
