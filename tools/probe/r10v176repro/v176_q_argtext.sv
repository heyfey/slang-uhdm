// r10v176 arm Q — VERIFIER.  THE RECEIVER-TEXT GATE UNDER STRESS.  The window
// r10uvm176 opens is decided from the RAW SOURCE TEXT left of the LAST dot in
// `expr.sourceRange` — so anything that puts a `.` or a `:` into that text
// decides the gate.  This arm writes every legal SV that does, plus the
// nesting cases.  MEASUREMENT ONLY.
package board_ZZ;
   int    peg_ZZ  = 4;
   parameter int IDX_ZZ = 1;
endpackage

interface duct_ZZ;
   int   held_ZZ;
   function automatic void feed_ZZ(int lot_ZZ, int par_ZZ);
      held_ZZ = lot_ZZ + par_ZZ;
   endfunction
   function automatic void solo_ZZ(int lot_ZZ);
      held_ZZ = lot_ZZ;
   endfunction
   function automatic int gauge_ZZ(int lot_ZZ);
      return lot_ZZ + 1;
   endfunction
endinterface

class Crate_ZZ;
   int  lid_ZZ;
endclass

class Loader_ZZ;
   virtual duct_ZZ  hose_ZZ;
   virtual duct_ZZ  rack_ZZ [3];
   Crate_ZZ         box_ZZ;
   int              own_ZZ;

   // Q1 — an ARGUMENT that itself contains a DOT (a class-property read).
   //      The receiver text is ONE name, but the last dot in the call's raw
   //      text belongs to the ARGUMENT.
   function void q1_dotarg(int able_ZZ);
      hose_ZZ.feed_ZZ(box_ZZ.lid_ZZ, able_ZZ);      // t_dot_in_arg
   endfunction

   // Q2 — the CONTROL for Q1: identical call, no dot in the argument.
   function void q2_nodot(int baker_ZZ);
      hose_ZZ.feed_ZZ(own_ZZ, baker_ZZ);            // t_no_dot
   endfunction

   // Q3 — an argument with a `::` (package variable) and NO dot.
   function void q3_scopedarg(int carl_ZZ);
      hose_ZZ.feed_ZZ(board_ZZ::peg_ZZ, carl_ZZ);   // t_scope_in_arg
   endfunction

   // Q4 — a SUBSCRIPTED receiver whose index carries a `::`.
   function void q4_scopedidx(int dog_ZZ);
      rack_ZZ[board_ZZ::IDX_ZZ].solo_ZZ(dog_ZZ);    // t_scope_in_recv
   endfunction

   // Q5 — a SUBSCRIPTED receiver whose index is a plain local (the control
   //      for Q4).
   function void q5_plainidx(int easy_ZZ);
      rack_ZZ[own_ZZ].solo_ZZ(easy_ZZ);             // t_local_idx_recv
   endfunction

   // Q6 — an interface call NESTED inside another interface call's argument.
   function void q6_nested(int fox_ZZ);
      hose_ZZ.solo_ZZ(rack_ZZ[0].gauge_ZZ(fox_ZZ)); // t_outer / t_inner
   endfunction

   // Q7 — an interface call in the ARGUMENT of an ORDINARY receiver-qualified
   //      call (§ classInBodyRecvCallArgNoBind52's silencer must survive).
   function void q7_under52(int golf_ZZ);
      own_ZZ = box_ZZ.lid_ZZ + hose_ZZ.gauge_ZZ(golf_ZZ);   // t_under_expr
   endfunction

   // Q8 — the argument is `this.`-qualified (a dot AFTER the receiver dot).
   function void q8_thisarg(int hotel_ZZ);
      hose_ZZ.feed_ZZ(this.own_ZZ, hotel_ZZ);       // t_this_in_arg
   endfunction

   // Q9 — the argument is a STRING LITERAL that CONTAINS A DOT.
   function void q9_dotliteral(int india_ZZ);
      hose_ZZ.feed_ZZ(india_ZZ, $sformatf("a.b").len());  // t_dot_literal
   endfunction

   // Q10 — a call written across TWO LINES with the dot on the second.
   function void q10_multiline(int juliet_ZZ);
      hose_ZZ
        .solo_ZZ(juliet_ZZ);                        // t_multiline
   endfunction
endclass

module rig_ZZ;
   duct_ZZ    pipe_a_ZZ ();
   duct_ZZ    pipe_b_ZZ ();
   Loader_ZZ  crew_ZZ;
   initial begin
      crew_ZZ = new();
      crew_ZZ.box_ZZ = new();
      crew_ZZ.hose_ZZ = pipe_a_ZZ;
      crew_ZZ.rack_ZZ[0] = pipe_b_ZZ;
      crew_ZZ.rack_ZZ[1] = pipe_a_ZZ;
      crew_ZZ.q1_dotarg(1);
      crew_ZZ.q2_nodot(2);
      crew_ZZ.q3_scopedarg(3);
      crew_ZZ.q5_plainidx(5);
      crew_ZZ.q6_nested(6);
      crew_ZZ.q8_thisarg(8);
      crew_ZZ.q10_multiline(10);
   end
endmodule
