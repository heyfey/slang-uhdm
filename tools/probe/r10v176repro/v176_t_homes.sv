// r10v176 arm T — VERIFIER.  THE FIX'S GATE BOUNDARY.  § 52's silencer reads
// `curSubClassScope9 && !curSubOob9`, so an OUT-OF-BODY method, a MODULE
// function and an INTERFACE's own subroutine are all OUTSIDE it.  This arm
// writes the EXPRESSION-position, SUBSCRIPTED-receiver call (the shape the
// verifier fix silences) in each of those homes, so the boundary is measured
// rather than assumed.  MEASUREMENT ONLY.  LHS is always golden.
interface vent_66;
   int   air_66;
   function automatic int puff_66(int gust_66);
      return gust_66 + 1;
   endfunction
endinterface

package attic_66;
   // an OUT-OF-BODY method (outside § 52's gate)
   class Fan_66;
      virtual vent_66 duct_66 [2];
      int             rpm_66;
      extern function void t1_oob_expr(int alpha_66);
      // the IN-BODY twin, same body (inside § 52's gate)
      function void t2_inbody_expr(int bravo_66);
         rpm_66 = duct_66[1].puff_66(bravo_66);      // h_inbody_expr
      endfunction
      // the IN-BODY STATEMENT twin (the law's own face, must keep binding)
      function void t3_inbody_stmt(int charm_66);
         rpm_66 = 0;
         t4_sink_66(duct_66[1].puff_66(charm_66));   // h_inbody_nested
      endfunction
      function void t4_sink_66(int delta_66);
         rpm_66 = delta_66;
      endfunction
   endclass

   function void Fan_66::t1_oob_expr(int alpha_66);
      rpm_66 = duct_66[1].puff_66(alpha_66);         // h_oob_expr
   endfunction
endpackage

// a $unit-scope class
class Loose_66;
   virtual vent_66 duct_66 [2];
   int             rpm_66;
   function void t5_unit_expr(int echo_66);
      rpm_66 = duct_66[1].puff_66(echo_66);          // h_unit_expr
   endfunction
endclass

module blower_66 (vent_66 pipe_66 [2]);
   int spin_66;
   // a MODULE function (outside § 52's gate) — must not move
   function void t6_mod_expr(int fox_66);
      spin_66 = pipe_66[1].puff_66(fox_66);          // h_mod_expr
   endfunction
   initial spin_66 = 0;
endmodule

// an INTERFACE's own subroutine (outside § 52's gate) — must not move
interface shaft_66;
   vent_66 kid_66 [2] ();
   int     turn_66;
   function automatic void t7_iface_expr(int golf_66);
      turn_66 = kid_66[1].puff_66(golf_66);          // h_iface_expr
   endfunction
endinterface

module top_66;
   vent_66  bank_66 [2] ();
   shaft_66 rod_66 ();
   blower_66 fan_u_66 (.pipe_66(bank_66));
   attic_66::Fan_66 f_66;
   Loose_66         l_66;
   initial begin
      f_66 = new();  l_66 = new();
      f_66.duct_66[1] = bank_66[1];
      l_66.duct_66[1] = bank_66[1];
      f_66.t1_oob_expr(1);
      f_66.t2_inbody_expr(2);
      f_66.t3_inbody_stmt(3);
      l_66.t5_unit_expr(5);
      rod_66.t7_iface_expr(7);
   end
endmodule
