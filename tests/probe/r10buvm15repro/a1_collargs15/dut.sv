// r10buvm15repro/a1_collargs15.sv — THE ARM for
// § retNameRecvCollapseArgsBindLikeBody15.
//
// ONE question per cell: inside a § retNameRecvCollapse69 COLLAPSED call
// (`<return-variable>.<method>(args);` in STATEMENT position), does golden give
// each ARGUMENT a vpiActual, and does it give the SAME answer an ORDINARY
// in-body call's argument list gets (§ classArgBind12) at the same control
// depth?
//
// AXES: argument symbol class (formal / body local / block local / class
// property / package var / literal / call / operation), enclosing-method flavour
// (non-static in-body / STATIC in-body / OUT-OF-BODY), control depth (top level
// vs inside an if-begin), and the collapsed/uncollapsed contrast in the SAME
// body as the control.
package p15;
   int pkgvar15 = 7;
   class helper15;
      int hprop;
      function void hset(int a, int b); hprop = a + b; endfunction
      function void hone(int a); hprop = a; endfunction
   endclass

   class target15;
      int tprop;
      function void tset(int a, int b); tprop = a + b; endfunction
   endclass

   // A package FREE function whose return variable is the receiver.
   // si=1 in the census (a package function carries a vpiInstance), so this is
   // the "binds everywhere" control.
   function automatic helper15 pkgcoll15(int pf1, int pf2);
      int ploc = 3;
      pkgcoll15 = new();
      pkgcoll15.hset(pf1, pf2);      // c01 collapsed, formals, pkg function
      pkgcoll15.hset(ploc, pkgvar15);// c02 collapsed, body local + pkg var
   endfunction

   class body15;
      int cprop15 = 1;
      helper15 h15;

      // NON-STATIC in-body method, collapsed call at TOP LEVEL.
      function helper15 mk15(int f1, int f2);
         int loc15 = 5;
         mk15 = new();
         mk15.hset(f1, f2);          // c10 collapsed, FORMAL args, depth 0
         mk15.hset(loc15, f1);       // c11 collapsed, body LOCAL + formal
         mk15.hset(cprop15, 4);      // c12 collapsed, class PROPERTY + literal
         mk15.hset(pkgvar15, f2);    // c13 collapsed, PACKAGE var + formal
         mk15.hone(id15(f1));        // c14 collapsed, a CALL as the argument
         mk15.hone(f1 + loc15);      // c15 collapsed, an OPERATION
         h15.hset(f1, f2);           // c16 CONTROL: uncollapsed method call
         sink15(f1, loc15);          // c17 CONTROL: plain user call
         $display("%0d %0d", f1, loc15); // c18 CONTROL: system call, binds none
         if (f1 != 0) begin
            mk15.hset(f1, f2);       // c19 collapsed, INSIDE an if-begin
            h15.hset(f1, f2);        // c20 CONTROL: uncollapsed, same depth
         end
      endfunction

      // STATIC in-body method — the BuildUVMPkg head's own flavour
      // (`static function uvm_cause_effect_link get_link(...)`).
      static function helper15 smk15(int s1, int s2);
         int sloc = 6;
         smk15 = new();
         smk15.hset(s1, s2);         // c30 collapsed, formals, STATIC method
         smk15.hset(sloc, s2);       // c31 collapsed, body local, STATIC
         if (s1 != 0) begin
            smk15.hset(s1, s2);      // c32 collapsed, STATIC, inside if-begin
         end
      endfunction

      // A BLOCK LOCAL declared in an unnamed block at the same control depth
      // (§ blockLocalSameCtrlDepthArgBinds57's population).
      function helper15 blk15(int b1);
         blk15 = new();
         begin
            int bl15 = 9;
            blk15.hset(bl15, b1);    // c40 collapsed, BLOCK local + formal
            sink15(bl15, b1);        // c41 CONTROL: plain call, same block
         end
      endfunction

      // A BUILT-IN method on the return variable (the SECOND collapse arm).
      function int q15(int qf);
         int qloc = 2;
         q15 = 0;
         qq15.push_back(qf);         // c50 collapsed BUILT-IN, formal
         qq15.push_back(qloc);       // c51 collapsed BUILT-IN, body local
      endfunction
      int qq15[$];

      function int id15(int x); return x; endfunction
      function void sink15(int a, int b); cprop15 = a + b; endfunction

      // OUT-OF-BODY declaration — § retNameRecvCollapse69 gate (b) says the
      // method shape is KEPT here, so these are the not-collapsed controls.
      extern function helper15 oob15(int o1, int o2);
   endclass

   function helper15 body15::oob15(int o1, int o2);
      int oloc = 8;
      oob15 = new();
      oob15.hset(o1, o2);            // c60 OUT-OF-BODY, formals
      if (o1 != 0) begin
         oob15.hset(o1, oloc);       // c61 OUT-OF-BODY, inside an if-begin
      end
   endfunction
endpackage

module top15;
   import p15::*;
   body15 b;
   initial begin
      b = new();
      void'(b.mk15(1, 2));
      void'(body15::smk15(3, 4));
      void'(b.blk15(5));
      void'(b.q15(6));
      void'(b.oob15(7, 8));
      void'(pkgcoll15(9, 10));
   end
endmodule
