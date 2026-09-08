// § ifaceOwnCallCalleeFormRoutes222 — ARM a5, THE ESCAPED-RECEIVER EDGE.
// The gate this pass installs reads the CALLEE text — everything before the
// argument list's opening paren — where the pristine code read the whole
// statement's LAST dot.  An ESCAPED receiver identifier CONTAINS a dot, so it
// is the spelling that proves the two readings still agree wherever the callee
// really is receiver-qualified.  (The other separating spelling, a receiver
// that is itself a CALL, is in a6_reject.sv: slang REFUSES it, so it can never
// reach this emitter at all.)
class obj22e;
   string p22e;
   function string path22e();
      return p22e;
   endfunction
endclass

interface if22e;
   function void poke22e(string a_name, int a_kind);
   endfunction
endinterface

module mod22e;
   if22e \u.esc22e ();
   obj22e o22e;

   // e02 the receiver is an ESCAPED instance name containing a dot.
   function void e02_escrecv();
      \u.esc22e .poke22e("y", 2);
   endfunction

   // e04 escaped receiver AND a receiver-qualified argument — the two
   //     features crossed.
   function void e04_escarg();
      \u.esc22e .poke22e(o22e.path22e(), 4);
   endfunction
endmodule
