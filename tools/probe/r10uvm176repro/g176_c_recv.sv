// r10uvm176 arm C — THE RECEIVER SPELLINGS.  One class, one method per way of
// naming the interface handle the call goes through.  The point of the arm is
// the SPELLING, so the argument is the SAME kind everywhere (the enclosing
// method's own formal) and only the receiver text varies.  MEASUREMENT ONLY.
interface node_if176;
   int  cell176;
   function automatic void poke176(int val176);
      cell176 = val176;
   endfunction
endinterface

class inner176;
   virtual node_if176 deep176;
endclass

class spelling176;
   virtual node_if176 plain176;        // ONE name
   virtual node_if176 bank176[3];      // an ARRAY of handles
   inner176           nest176;         // a class holding a handle

   // ---- C1: one plain name (the corpus spelling)
   function void c1_plain(int alfa176);
      plain176.poke176(alfa176);          // s_plain
   endfunction

   // ---- C2: `this.`-rooted  (Surelog routes this through
   //          compileComplexFuncCall, NOT compileTfCall's dotted arm)
   function void c2_this(int beta176);
      this.plain176.poke176(beta176);     // s_this
   endfunction

   // ---- C3: a TWO-name receiver (`nest.deep.poke`)
   function void c3_deep(int gamma176);
      nest176.deep176.poke176(gamma176);  // s_deep
   endfunction

   // ---- C4: a SUBSCRIPTED receiver
   function void c4_index(int delta176);
      bank176[1].poke176(delta176);       // s_index
   endfunction

   // ---- C5: a LOCAL handle copied out of the property first
   function void c5_local(int epsil176);
      virtual node_if176 grab176;
      grab176 = plain176;
      grab176.poke176(epsil176);          // s_local
   endfunction

   // ---- C6: the handle arrives as the method's OWN FORMAL
   function void c6_formal(virtual node_if176 held176, int zeta176);
      held176.poke176(zeta176);           // s_formal
   endfunction

   // ---- C7: a receiver written with WHITESPACE around the dot
   function void c7_spaced(int eta176);
      plain176 . poke176(eta176);         // s_spaced
   endfunction

   // ---- C8: a CLASS-SCOPED receiver (`cls::stat.meth()`).  Surelog's
   //          `compileTfCall` sends a `paClass_scope` leaf to
   //          `compileComplexFuncCall`, never to the dotted arm this law
   //          lives in, so the window must decline on a `::` in the receiver.
   static virtual node_if176 stat176;
   function void c8_scoped(int theta176);
      spelling176::stat176.poke176(theta176);   // s_scoped
   endfunction
endclass

module top176;
   node_if176   box176();
   spelling176  sp176;
   initial begin
      sp176 = new();
      sp176.plain176 = box176;
      sp176.nest176 = new();
      sp176.nest176.deep176 = box176;
      sp176.bank176[1] = box176;
      sp176.c1_plain(1);
      sp176.c2_this(2);
      sp176.c3_deep(3);
      sp176.c4_index(4);
      sp176.c5_local(5);
      sp176.c6_formal(box176, 6);
      sp176.c7_spaced(7);
   end
endmodule
