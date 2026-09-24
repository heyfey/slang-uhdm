// r10uvm56 VERIFIER arm v1 — THE SCOPES THE IMPLEMENTER'S a3 DID NOT BUILD.
// a3 puts its class in a PACKAGE only.  § classMethodRetNameNoBind56's real
// predicate is `classMethod37 && VpiMethod()`, and VpiMethod() is set for
// `protoOf || ((designScope || classScope) && (!oob || oobCtor))` — classScope
// with no regard to WHERE the class was declared.  So an in-body method of a
// class declared in a MODULE, at $unit scope, or inside an INTERFACE all take
// the drop too, and none of those was measured.  Golden side is the authority.

// (v1a) class at $unit / compilation-unit scope
class u1;
   function int u_in(int y);
      u_in = y + 1;
      if (u_in > 3)
        u_in = 3;
   endfunction
endclass

interface v1_if;
   // (v1c) class declared INSIDE AN INTERFACE
   class i1;
      function int i_in(int y);
         i_in = y + 1;
         if (i_in > 3)
           i_in = 3;
      endfunction
   endclass
   // (v1d) a plain FUNCTION inside an interface (not a class method)
   function int ifn(int y);
      ifn = y + 1;
      if (ifn > 3)
        ifn = 3;
   endfunction
endinterface

module v1_top;
   // (v1b) class declared INSIDE A MODULE
   class m1;
      function int m_in(int y);
         m_in = y + 1;
         if (m_in > 3)
           m_in = 3;
      endfunction
   endclass

   int r;
   u1 hu;
   m1 hm;
   initial begin
      hu = new();
      hm = new();
      r = hu.u_in(1) + hm.m_in(1);
   end
endmodule
