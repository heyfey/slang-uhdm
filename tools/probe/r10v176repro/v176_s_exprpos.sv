// r10v176 arm S — VERIFIER.  THE REGRESSION FACE, isolated.
// § classInBodyRecvCallArgNoBind52 is a SILENCER raised around the argument
// list of every EXPRESSION-POSITION receiver-qualified call.  The interface-
// method arm r10uvm176 opened its window in NEVER raised it (pass 52 windowed
// the three hier_path mints, not this arm), which was invisible while
// `classMethodNoBind` silenced those arguments anyway.  This arm writes the
// same call in STATEMENT position and in every EXPRESSION position, with a
// PLAIN one-name receiver (which our emitter routes to the hier_path arm, so
// § 52 already covers it) and with a SUBSCRIPTED receiver (which reaches the
// interface arm).  MEASUREMENT ONLY.  LHS is always golden.
interface gate_77;
   int   count_77;
   function automatic int weigh_77(int load_77);
      return load_77 + 1;
   endfunction
   function automatic void set_77(int load_77);
      count_77 = load_77;
   endfunction
endinterface

class Judge_77;
   virtual gate_77 lone_77;         // ONE-name receiver
   virtual gate_77 row_77 [4];      // SUBSCRIPTED receiver
   int             score_77;

   // ---- STATEMENT position (the law's own face) --------------------------
   function void s1_stmt_plain(int alpha_77);
      lone_77.set_77(alpha_77);                     // e_stmt_plain
   endfunction
   function void s2_stmt_index(int bravo_77);
      row_77[2].set_77(bravo_77);                   // e_stmt_index
   endfunction

   // ---- EXPRESSION position: ASSIGNMENT RHS ------------------------------
   function void s3_asg_plain(int chase_77);
      score_77 = lone_77.weigh_77(chase_77);        // e_asg_plain
   endfunction
   function void s4_asg_index(int drift_77);
      score_77 = row_77[2].weigh_77(drift_77);      // e_asg_index
   endfunction

   // ---- EXPRESSION position: an IF CONDITION -----------------------------
   function void s5_cond_plain(int ember_77);
      if (lone_77.weigh_77(ember_77) == 0)
         score_77 = 1;                              // e_cond_plain
   endfunction
   function void s6_cond_index(int flint_77);
      if (row_77[2].weigh_77(flint_77) == 0)
         score_77 = 2;                              // e_cond_index
   endfunction

   // ---- EXPRESSION position: RETURN --------------------------------------
   function int s7_ret_plain(int grove_77);
      return lone_77.weigh_77(grove_77);            // e_ret_plain
   endfunction
   function int s8_ret_index(int hasty_77);
      return row_77[2].weigh_77(hasty_77);          // e_ret_index
   endfunction

   // ---- EXPRESSION position: an OPERAND of an arithmetic expression ------
   function void s9_oper_index(int ivory_77);
      score_77 = row_77[2].weigh_77(ivory_77) + 3;  // e_oper_index
   endfunction

   // ---- EXPRESSION position: inside ANOTHER call's argument list ---------
   function void s10_nest_index(int jolly_77);
      lone_77.set_77(row_77[2].weigh_77(jolly_77)); // e_nest_index
   endfunction
   function void s11_nest_plain(int knoll_77);
      lone_77.set_77(lone_77.weigh_77(knoll_77));   // e_nest_plain
   endfunction

   // ---- the SAME subscripted receiver, statement position, ONE control
   //      body down (the depth control) -----------------------------------
   function void s12_deep_index(int larch_77);
      if (score_77 > 0) begin
         row_77[2].set_77(larch_77);                // e_deep_index
      end
   endfunction
endclass

module bench_77;
   gate_77  door_77 ();
   Judge_77 who_77;
   initial begin
      who_77 = new();
      who_77.lone_77 = door_77;
      who_77.row_77[2] = door_77;
      who_77.s1_stmt_plain(1);
      who_77.s2_stmt_index(2);
      who_77.s3_asg_plain(3);
      who_77.s4_asg_index(4);
      who_77.s5_cond_plain(5);
      who_77.s6_cond_index(6);
      who_77.s9_oper_index(9);
      who_77.s10_nest_index(10);
      who_77.s11_nest_plain(11);
      who_77.s12_deep_index(12);
   end
endmodule
