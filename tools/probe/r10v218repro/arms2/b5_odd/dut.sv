// r10v218 arm b5 — the ODD SUBROUTINE SHAPES an uninstantiated interface can
// hold: a modport IMPORT, an EXTERN prototype with an out-of-interface body,
// a `void'()` cast call, a chained receiver, and a function used as a task.
class d5v;
   function void take(int x); endfunction
   function d5v  self(); return this; endfunction
endclass

interface if5v;
   bit mv5v;
   d5v h5v;
   modport mp5v (import fimp5v, input mv5v);

   function void fimp5v(int a_i);
      int li5v;
      if (a_i == 1) mv5v = 1'b1;        // o01 modport-IMPORTED fn, formal cond
      if (li5v == 1) mv5v = 1'b1;       // o02 modport-IMPORTED fn, local cond
      c5v(a_i);                         // o03 call-stmt arg
      c5v(li5v);                        // o04 call-stmt arg, local
   endfunction

   function void fodd5v(int a_o);
      int lo5v;
      void'(g5v(a_o));                  // o05 arg under a VOID CAST call
      h5v.self().take(a_o);             // o06 CHAINED receiver, stmt position
      c5v(g5v(a_o) + lo5v);             // o07 nested call + local, one arg
      if (h5v.self() != null) mv5v = 1; // o08 chained receiver in a cond
      c5v(a_o);                         // o09 plain control
   endfunction

   function void c5v(int z); endfunction
   function int  g5v(int z); return z; endfunction
endinterface

module top5v;
   initial begin end
endmodule
