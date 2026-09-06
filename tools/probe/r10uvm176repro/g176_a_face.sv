// r10uvm176 arm A — THE FACE.  A call through a VIRTUAL INTERFACE handle in
// STATEMENT position, and every neighbour that must NOT move with it.
// MEASUREMENT ONLY.  Cell names are deliberately UNLIKE each other (RESUME.md
// §9: a grid that names everything a_t/b_t/c_t is self-confirming).
interface bus_if176;
   string  lbl176;
   task automatic stow176(string tag176);
      lbl176 = tag176;
   endtask
   function automatic void mark176(string tag176);
      lbl176 = tag176;
   endfunction
   function automatic int size176(string tag176);
      return tag176.len();
   endfunction
endinterface

class helper176;
   string kept176;
   function void keep176(string tag176);
      kept176 = tag176;
   endfunction
   function int ask176(string tag176);
      return tag176.len();
   endfunction
endclass

class rider176;
   virtual bus_if176 wire176;      // the virtual-interface property
   helper176         mate176;      // an ordinary class handle (the control)
   string            prop176;      // a class PROPERTY
   int               tally176;

   // ---- A1: the CORPUS FACE — a FUNCTION call through a vif, statement
   // position, argument is the enclosing FUNCTION's own FORMAL.
   function void a1_vfunc(string alpha176);
      prop176 = alpha176;                 // c_asg   assignment rhs (bare both)
      wire176.mark176(alpha176);          // c_vfn_formal
   endfunction

   // ---- A2: a TASK call through the same vif.
   task a2_vtask(string bravo176);
      wire176.stow176(bravo176);          // c_vtk_formal
   endtask

   // ---- A3: the argument is a BODY LOCAL, not a formal.
   function void a3_local();
      string charlie176;
      charlie176 = "x";
      wire176.mark176(charlie176);        // c_vfn_local
   endfunction

   // ---- A4: the argument is a CLASS PROPERTY.
   function void a4_prop();
      wire176.mark176(prop176);           // c_vfn_prop
   endfunction

   // ---- A5: the argument is a LITERAL.
   function void a5_lit();
      wire176.mark176("delta176");        // c_vfn_lit
   endfunction

   // ---- A6: EXPRESSION position through the vif.
   function int a6_expr(string echo176);
      return wire176.size176(echo176);    // c_vfn_expr
   endfunction

   // ---- A7: EXPRESSION position, operand of a comparison in an assignment.
   function void a7_operand(string fox176);
      tally176 = wire176.size176(fox176) + 1;   // c_vfn_oper
   endfunction

   // ---- A8: the CONTROL — an ordinary CLASS-handle receiver, statement
   // position.  golden BINDS; this must not move.
   function void a8_class(string golf176);
      mate176.keep176(golf176);           // c_cls_formal
   endfunction

   // ---- A9: the CONTROL — an ordinary class handle in EXPRESSION position.
   function int a9_clsexpr(string hotel176);
      return mate176.ask176(hotel176);    // c_cls_expr
   endfunction

   // ---- A10: a RECEIVER-LESS call in the same body (control).
   function void a10_bare(string india176);
      keep_local176(india176);            // c_bare_formal
   endfunction
   function void keep_local176(string juliet176);
      prop176 = juliet176;
   endfunction

   // ---- A11: `this.`-qualified vif receiver.
   function void a11_thisvif(string kilo176);
      this.wire176.mark176(kilo176);      // c_this_vif
   endfunction

   // ---- A12: TWO arguments through the vif (multiplicity).
   task a12_two(string lima176, string mike176);
      wire176.mark176(lima176);           // c_vfn_two_a
      wire176.stow176(mike176);           // c_vtk_two_b
   endtask

   // ---- A13: a vif call inside an `if` BODY (control-body depth 1).
   function void a13_depth(string november176);
      if (tally176 > 0) begin
         wire176.mark176(november176);    // c_vfn_depth1
      end
   endfunction

   // ---- A14: a vif call whose argument is an EXPRESSION over a formal.
   function void a14_oparg(string oscar176);
      wire176.mark176({oscar176, "z"});   // c_vfn_concat
   endfunction
endclass

module top176;
   bus_if176 inst176();
   rider176  who176;
   initial begin
      who176 = new();
      who176.wire176 = inst176;
      who176.a1_vfunc("p");
   end
endmodule
