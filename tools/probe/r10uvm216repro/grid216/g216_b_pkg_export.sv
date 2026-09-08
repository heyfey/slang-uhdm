// r10uvm216 ARM B — THE PACKAGE CONTROL (MUST-STAY).  The same shape in a
// PACKAGE.  We ALREADY agree with golden on `uvm_pkg::m__uvm_report_dpi`
// (index 354 of the MiniAmiq interface listing, `acc=EXPORT cstr=2` on BOTH
// sides), but there the `export` and the definition are ADJACENT lines
// (uvm_globals.svh:161/162) so the ORDER question is invisible.  This arm
// separates them, so it says whether the package path already answers the
// position question or merely was never asked it.
package b216_pkg;
   import "DPI-C" context function void b216_imp(input int x);

   export "DPI-C" function b216_second;
   export "DPI-C" function b216_first;

   int b216_state;

   function void b216_plain1(int p);
      b216_state = p;
   endfunction

   function int b216_plain2(int p);
      return p + 1;
   endfunction

   function void b216_first(input int a, input string b);
      b216_state = a;
      b216_imp(a);
   endfunction

   function int b216_second(input int a);
      return a + b216_state;
   endfunction

   function void b216_plain4();
      b216_state = 0;
   endfunction
endpackage

module b216_top();
   import b216_pkg::*;
   initial b216_plain4();
endmodule
