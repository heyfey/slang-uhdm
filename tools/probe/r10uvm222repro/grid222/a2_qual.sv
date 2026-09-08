// § ifaceOwnCallCalleeFormRoutes222 — ARM a2, THE MUST-STAY FACE.
// Calls whose CALLEE IS ITSELF receiver-qualified and whose callee lives in an
// interface: the arm this pass narrows was decoded on exactly these, and every
// one of them must keep the `method_func_call{vpiPrefix}` shape.  The
// argument spellings are varied under each so that "a dot in the argument
// list" can never be what decides.
class obj22b;
   string p22b;
   function string path22b();
      return p22b;
   endfunction
   function int num22b();
      return 3;
   endfunction
endclass

interface if22b;
   function void poke22b(string a_name, int a_kind);
   endfunction
   function int weigh22b(int a_x);
      return a_x;
   endfunction
endinterface

module mid22b(if22b vif22b);
   obj22b o22b;
   int x22b;

   // q01 QUALIFIED callee, PLAIN argument.               must stay a method call
   function void q01_plain(string a_s);
      vif22b.poke22b(a_s, 1);
   endfunction

   // q02 QUALIFIED callee, RECEIVER-QUALIFIED CALL argument.
   //     The pristine emitter split this on the LAST dot and named the prefix
   //     `vif22b.poke22b(o22b`; the callee's own form says `vif22b`.
   function void q02_recvarg();
      vif22b.poke22b(o22b.path22b(), 2);
   endfunction

   // q03 QUALIFIED callee, PLAIN DOTTED NAME argument.
   function void q03_dotarg();
      vif22b.poke22b(o22b.p22b, 3);
   endfunction

   // q04 QUALIFIED callee, SPACED dot.
   function void q04_spaced(string a_s);
      vif22b . poke22b(a_s, 4);
   endfunction

   // q05 QUALIFIED callee, spaced dot AND a receiver-qualified argument.
   function void q05_spacedarg();
      vif22b . poke22b(o22b.path22b(), 5);
   endfunction

   // q06 QUALIFIED callee in EXPRESSION position, plain argument.
   function int q06_expr(int a_x);
      return vif22b.weigh22b(a_x);
   endfunction

   // q07 QUALIFIED callee in EXPRESSION position, receiver-qualified argument.
   function int q07_exprarg();
      return vif22b.weigh22b(o22b.num22b());
   endfunction

   // q08 QUALIFIED callee, argument list EMPTY-parens twin (no dot at all).
   function void q08_noargs();
      vif22b.poke22b("", 8);
   endfunction
endmodule

module toph22b;
   if22b u_if22b();
   mid22b u_mid22b(u_if22b);
endmodule
