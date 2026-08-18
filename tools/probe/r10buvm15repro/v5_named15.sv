// vbuvm15 VERIFIER ARM 5 — THE NAMED-BLOCK DISCRIMINATOR.
// v2_shadow15.sv cell s34 is a PRISTINE-RIGHT -> PATCHED-WRONG cell: a local
// declared in a NAMED statement block, passed to a COLLAPSED call, is BARE in
// golden and BARE on the pristine binary and BOUND on the patched one.
// This arm separates the two questions that cell raises:
//   (1) is the NAMED block the discriminator, or the block depth?
//   (2) does the ORDINARY § classArgBind12 window (an uncollapsed user call, a
//       built-in method call) already over-bind a named-block local on the
//       PRISTINE binary -- i.e. is the defect pre-existing and merely inherited,
//       or is it introduced here?
package pn15;
   class hn15;
      int hp;
      function void one(int a); hp = a; endfunction
   endclass
   class cn15;
      int cprop = 1;
      hn15 hh;
      function void sink(int a); cprop = a; endfunction
      function int sink2(int a); return a; endfunction

      function hn15 mkn15(int f1);
         int bodyloc = 2;
         mkn15 = new();
         begin                       // UNNAMED block
            int uloc = 3;
            mkn15.one(uloc);         // n10 COLLAPSED, UNNAMED-block local
            sink(uloc);              // n11 ORDINARY call, UNNAMED-block local
            hh.one(uloc);            // n12 BUILT-IN-shaped method call, same
         end
         nb15: begin                 // NAMED block
            int nloc = 4;
            mkn15.one(nloc);         // n20 COLLAPSED, NAMED-block local
            sink(nloc);              // n21 ORDINARY call, NAMED-block local
            hh.one(nloc);            // n22 method call, NAMED-block local
            mkn15.one(f1);           // n23 COLLAPSED, FORMAL in a named block
            sink(f1);                // n24 ORDINARY call, FORMAL, named block
            mkn15.one(bodyloc);      // n25 COLLAPSED, BODY local, named block
            sink(bodyloc);           // n26 ORDINARY call, BODY local, named blk
            mkn15.one(sink2(nloc));  // n27 COLLAPSED outer, NESTED ordinary call
            sink(sink2(nloc));       // n28 ORDINARY outer, NESTED ordinary call
         end
         nb2: begin                  // NAMED block, nested UNNAMED inside
            int n2loc = 5;
            begin
               int i2loc = 6;
               mkn15.one(i2loc);     // n30 COLLAPSED, inner UNNAMED local
               mkn15.one(n2loc);     // n31 COLLAPSED, outer NAMED-block local
               sink(i2loc);          // n32 ORDINARY, inner UNNAMED local
               sink(n2loc);          // n33 ORDINARY, outer NAMED-block local
            end
         end
      endfunction

      // The same two blocks in an OUT-OF-BODY method (binds everywhere).
      extern function hn15 oobn15(int o1);
   endclass
   function hn15 cn15::oobn15(int o1);
      oobn15 = new();
      onb: begin
         int oloc = 7;
         oobn15.one(oloc);           // n40 OOB, NAMED-block local
         sink(oloc);                 // n41 OOB, ORDINARY call
      end
   endfunction

   // A PACKAGE FREE function (si=1, classMethodNoBind never in force): the
   // window this pass opens cannot reach it, so whatever golden says here is a
   // PRE-EXISTING question, not this pass's.  Measured so the fix's class guard
   // is a measurement and not an assumption.
   function automatic hn15 pkgn15(int p1);
      pkgn15 = new();
      pnb: begin
         int ploc = 8;
         pkgn15.one(ploc);           // n50 PKG function, NAMED-block local
         pkgn15.one(p1);             // n51 PKG function, FORMAL in named block
      end
   endfunction
endpackage

module mn15;
   import pn15::*;
   cn15 c;
   initial begin
      c = new();
      void'(c.mkn15(1));
      void'(c.oobn15(2));
      void'(pkgn15(3));
   end
endmodule
