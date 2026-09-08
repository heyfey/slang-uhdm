// § ifaceOwnCallCalleeFormRoutes222 — ARM a6, THE SPELLING SLANG REFUSES.
// A receiver that is ITSELF A CALL (`get22e().poke22e(...)`) is the only other
// text the pristine LAST-dot split and this pass's CALLEE-form gate could
// disagree about: the last dot sits after a `(`, so the split accepts it and
// the callee-form read declines it.  slang REJECTS the construct outright
// ("invalid member access for type 'virtual interface if22e'", rc 3), so it
// never reaches our emitter on any input and the disagreement is unreachable.
// THE RC IS THE MEASUREMENT — this arm is recorded as an ERROR-RECOVERY arm,
// never as a golden one (uvm215's lesson).
class obj22f;
   string p22f;
   function string path22f();
      return p22f;
   endfunction
endclass

interface if22f;
   function void poke22f(string a_name, int a_kind);
   endfunction
endinterface

class drv22f;
   virtual if22f vif22f;
   obj22f o22f;
   function virtual if22f get22f();
      return vif22f;
   endfunction

   // f01 the receiver is a CALL, plain argument.
   function void f01_parenrecv();
      get22f().poke22f("x", 1);
   endfunction

   // f02 the receiver is a CALL, receiver-qualified argument.
   function void f02_parenarg();
      get22f().poke22f(o22f.path22f(), 2);
   endfunction
endclass

module mod22f;
   if22f u_if22f();
endmodule
