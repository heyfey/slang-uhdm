// r10uvm56 arm a3 — A FUNCTION AT EVERY SCOPE.  This campaign has three laws
// that turned out to be scope-bound, so the return-name binding is measured at
// class-IN-BODY, class-OUT-OF-BODY, module, package and generate-block scope in
// ONE database.
package p3;
   // package free function
   function int pf(int y);
      pf = y + 1;
      if (pf > 3)
        pf = 3;
   endfunction

   class c3;
      // IN-BODY class method
      function int m_in(int y);
         m_in = y + 1;
         if (m_in > 3)
           m_in = 3;
      endfunction
      // OUT-OF-BODY class method (declared here, defined below)
      extern function int m_out(int y);
   endclass

   // the out-of-body definition
   function int c3::m_out(int y);
      m_out = y + 1;
      if (m_out > 3)
        m_out = 3;
   endfunction
endpackage

module a3_top;
   // module-level function
   function int mf(int y);
      mf = y + 1;
      if (mf > 3)
        mf = 3;
   endfunction

   generate
      if (1) begin : gb
         // function inside a generate block
         function int gf(int y);
            gf = y + 1;
            if (gf > 3)
              gf = 3;
         endfunction
      end
   endgenerate

   int r;
   p3::c3 h;
   initial begin
      h = new();
      r = mf(1) + gb.gf(1) + p3::pf(1) + h.m_in(1) + h.m_out(1);
   end
endmodule
