// r10v176 arm R — VERIFIER.  MULTIPLICITY and the NON-VIRTUAL controls.
// A PARAMETERIZED class (three specialisations of the same body), the same
// call reached through a GENERATE block, an interface calling a nested
// interface, and a module instantiated 1/2/3 times.  MEASUREMENT ONLY.
interface tap_88;
   int   bucket_88;
   function automatic void pour_88(int drop_88);
      bucket_88 = drop_88;
   endfunction
   task automatic drain_88(int drop_88);
      bucket_88 = drop_88 - 1;
   endtask
endinterface

class Vessel_88 #(int CAP_88 = 1, type T_88 = int);
   virtual tap_88 spout_88;
   T_88           level_88;

   // R1 — the SAME body, compiled once per specialisation.
   function void r1_fill(T_88 mead_88);
      spout_88.pour_88(mead_88);              // v_spec_fill
   endfunction

   // R2 — a task, one control body down, in the same specialised class.
   task r2_sink(T_88 nectar_88);
      if (CAP_88 > 0) begin
         spout_88.drain_88(nectar_88);        // v_spec_deep
      end
   endtask
endclass

// R3 — an INTERFACE whose own subroutine calls a NESTED interface: the
// counter-witness home.  Must NOT move (the window declines outside a class).
interface hub_88;
   tap_88 kid_88 ();
   int    seen_88;
   function automatic void h1_relay(int oat_88);
      kid_88.pour_88(oat_88);                 // v_iface_home
   endfunction
   task automatic h2_deep(int pea_88);
      if (seen_88 > 0) begin
         kid_88.drain_88(pea_88);             // v_iface_home_deep
      end
   endtask
endinterface

// R4 — a MODULE with an interface PORT, reached from a GENERATE block and a
// module function.  Both are non-class homes; both must stay put.
module worker_88 #(parameter int LANE_88 = 0) (tap_88 feed_88);
   int gauge_88;
   function void w1_modfn(int rye_88);
      feed_88.pour_88(rye_88);                // v_mod_fn
   endfunction
   generate
      if (LANE_88 >= 0) begin : g_lane_88
         int barley_88;
         initial begin
            barley_88 = LANE_88;
            feed_88.pour_88(barley_88);       // v_gen_proc
         end
      end
   endgenerate
   initial begin
      gauge_88 = LANE_88 + 1;
      w1_modfn(gauge_88);
   end
endmodule

module top_88;
   tap_88 main_88 ();
   hub_88 relay_88 ();

   worker_88 #(.LANE_88(0)) w_one_88   (.feed_88(main_88));
   worker_88 #(.LANE_88(1)) w_two_88   (.feed_88(main_88));
   worker_88 #(.LANE_88(2)) w_three_88 (.feed_88(main_88));

   Vessel_88 #(1, int)       a_ves_88;
   Vessel_88 #(2, int)       b_ves_88;
   Vessel_88 #(3, shortint)  c_ves_88;

   initial begin
      a_ves_88 = new();  b_ves_88 = new();  c_ves_88 = new();
      a_ves_88.spout_88 = main_88;
      b_ves_88.spout_88 = main_88;
      c_ves_88.spout_88 = main_88;
      a_ves_88.r1_fill(1);
      b_ves_88.r1_fill(2);
      c_ves_88.r1_fill(3);
      b_ves_88.r2_sink(4);
      relay_88.h1_relay(5);
      relay_88.h2_deep(6);
   end
endmodule
