// r10buvm15repro/a2_collbuiltin15.sv — THE ARM for SITE 2, the BUILT-IN method
// half of § retNameRecvCollapseArgsBindLikeBody15.
//
// a1's `qq15.push_back(qf)` cell did NOT test it: the receiver there is a class
// PROPERTY, not the return variable, so the call never collapses.  Here the
// receiver IS the enclosing function's own return variable and the method is a
// BUILT-IN queue method — CrossFunc's `myFunc1.push_back('{i,i})` shape — in a
// class method (where classMethodNoBind is in force), in a STATIC class method,
// inside an if-begin (the control-depth discriminator) and in a package free
// function (the binds-everywhere control).
package q15p;
   typedef int iq15[$];
   int pkgv15 = 3;

   function automatic iq15 pkgq15(int pf);
      int ploc = 1;
      pkgq15.push_back(pf);          // d01 collapsed built-in, pkg function
      pkgq15.push_back(ploc);        // d02 collapsed built-in, body local
   endfunction

   class qcls15;
      int cprop15 = 2;
      int other15[$];

      function iq15 mkq15(int f1, int f2);
         int loc15 = 4;
         mkq15.push_back(f1);        // d10 collapsed built-in, FORMAL, depth 0
         mkq15.push_back(loc15);     // d11 collapsed built-in, body LOCAL
         mkq15.push_back(cprop15);   // d12 collapsed built-in, class PROPERTY
         mkq15.push_back(pkgv15);    // d13 collapsed built-in, PACKAGE var
         other15.push_back(f2);      // d14 CONTROL: uncollapsed built-in
         if (f1 != 0) begin
            mkq15.push_back(f2);     // d15 collapsed built-in, inside if-begin
            other15.push_back(f2);   // d16 CONTROL: uncollapsed, same depth
         end
      endfunction

      static function iq15 smkq15(int s1);
         int sloc = 5;
         smkq15.push_back(s1);       // d20 collapsed built-in, STATIC, depth 0
         smkq15.push_back(sloc);     // d21 collapsed built-in, STATIC, local
      endfunction

      extern function iq15 oobq15(int o1);
   endclass

   function iq15 qcls15::oobq15(int o1);
      int oloc = 6;
      oobq15.push_back(o1);          // d30 OUT-OF-BODY (gate b: no collapse)
      oobq15.push_back(oloc);        // d31 OUT-OF-BODY
   endfunction
endpackage

module topq15;
   import q15p::*;
   qcls15 c;
   initial begin
      c = new();
      void'(c.mkq15(1, 2));
      void'(qcls15::smkq15(3));
      void'(c.oobq15(4));
      void'(pkgq15(5));
   end
endmodule
