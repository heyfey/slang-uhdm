// g19 — BUILTIN ACTUALS.  The type arguments are unnamed builtin typespecs,
// not classes, exactly like the r10uvm54repro/a1 boundary cells.  ASCII-first
// is Aa19 (argument `byte`), so all three must bind Q to byte.
package p19box;
  class B19 #(type Q = int); int x19; endclass
endpackage
package p19use;
  import p19box::*;
  class Aa19; typedef B19 #(byte)      t19; endclass
  class mm19; typedef B19 #(shortint)  t19; endclass
  class zz19; typedef B19 #(longint)   t19; endclass
endpackage
