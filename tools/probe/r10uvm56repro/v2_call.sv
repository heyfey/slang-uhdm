// r10uvm56 VERIFIER arm v2 — THE REFERENCES THAT ARE NOT RETURN VARIABLES BUT
// CARRY THE SAME NAME.  The population § classMethodRetNameNoBind56 drops is
// `funcRetRefs`, pushed only when `&nv.symbol == funcRetSym`; this arm proves
// by measurement that the following are NOT in it and keep whatever binding
// they had:
//   (v2a) a CALL to an in-body class method from outside the class
//   (v2b) a CALL to the method from ANOTHER method of the same class
//   (v2c) a `super.f(...)` call to a base-class in-body method
//   (v2d) a method INHERITED by a derived class and called through the derived
//         handle (one body, two specialisations of the enclosing scope)
//   (v2e) a derived OVERRIDE that assigns its own return name and also calls
//         `super.f` — the return name and the call name are the SAME token
package p2;
   class base2;
      function int f2(int y);
         f2 = y + 1;         // return-name ref, in-body class method
         if (f2 > 3)
           f2 = 3;
      endfunction
      // (v2b) call the method from a sibling method of the same class
      function int caller2(int y);
         caller2 = f2(y) + 1;
      endfunction
   endclass

   class der2 extends base2;
      // (v2e) override: own return name AND a super call with the same name
      function int f2(int y);
         f2 = super.f2(y) + 1;
         if (f2 > 9)
           f2 = 9;
      endfunction
   endclass
endpackage

module v2_top;
   int r;
   p2::base2 hb;
   p2::der2 hd;
   initial begin
      hb = new();
      hd = new();
      // (v2a) call from outside the class, (v2d) inherited call via derived
      r = hb.f2(1) + hb.caller2(1) + hd.f2(1) + hd.caller2(1);
   end
endmodule
