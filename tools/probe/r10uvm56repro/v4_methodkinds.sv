// r10uvm56 VERIFIER arm v4 — THE IN-BODY CLASS METHOD KINDS THE IMPLEMENTER'S
// ARMS NEVER VARIED.  Every a-arm method is a plain non-static, non-virtual
// method of a plain non-parameterised, non-nested class.  § classMethodRetNameNoBind56
// fires on `classMethod37 && VpiMethod()` and VpiMethod() is also set by the
// `static` / `virtual` / prototype paths, so each of these is a place the drop
// could fire where golden might still bind:
//   (v4a) STATIC in-body method            (span collapses onto the qualifier)
//   (v4b) VIRTUAL in-body method           (span covers the whole declaration)
//   (v4c) LOCAL / PROTECTED in-body method (span collapses too)
//   (v4d) in-body method of a PARAMETERISED class, TWO specialisations
//   (v4e) in-body method of a NESTED class
//   (v4f) an override in a DERIVED class of a virtual base method
//   (v4g) the return name read inside a FOR loop and a CASE, not just an `if`
package p4;
   class c4;
      static function int s_in(int y);
         s_in = y + 1;
         if (s_in > 3)
           s_in = 3;
      endfunction
      virtual function int v_in(int y);
         v_in = y + 1;
         if (v_in > 3)
           v_in = 3;
      endfunction
      protected function int pr_in(int y);
         pr_in = y + 1;
         if (pr_in > 3)
           pr_in = 3;
      endfunction
      // (v4g) return name inside a for loop and a case statement
      function int loop_in(int y);
         loop_in = 0;
         for (int i = 0; i < 2; i++)
           loop_in = loop_in + y;
         case (y)
           0: loop_in = 1;
           default: loop_in = loop_in + 1;
         endcase
      endfunction
      // (v4e) NESTED class with an in-body method
      class n4;
         function int nn_in(int y);
            nn_in = y + 1;
            if (nn_in > 3)
              nn_in = 3;
         endfunction
      endclass
   endclass

   // (v4d) PARAMETERISED class, in-body method, two specialisations below
   class g4 #(int W = 1);
      function int g_in(int y);
         g_in = y + W;
         if (g_in > 3)
           g_in = 3;
      endfunction
   endclass

   // (v4f) derived override of a virtual in-body method
   class d4 extends c4;
      virtual function int v_in(int y);
         v_in = y + 2;
         if (v_in > 9)
           v_in = 9;
      endfunction
   endclass
endpackage

module v4_top;
   int r;
   p4::c4 h;
   p4::d4 hd;
   p4::g4 #(1) g1;
   p4::g4 #(2) g2;
   initial begin
      h = new();
      hd = new();
      g1 = new();
      g2 = new();
      r = p4::c4::s_in(1) + h.v_in(1) + h.loop_in(1) + hd.v_in(1) +
          g1.g_in(1) + g2.g_in(1);
   end
endmodule
