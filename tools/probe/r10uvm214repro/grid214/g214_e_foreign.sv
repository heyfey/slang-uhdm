// r10uvm214 grid arm E — A FOREIGN PACKAGE'S PARAMETER read from a def-view
// clone body, both spellings.  Surelog's `UhdmWriter::lateBinding`
// (UhdmWriter.cpp:3812-3821) matches the reference NAME against
// `m->Param_assigns()` of the COMPONENT BEING WRITTEN, so a reference to a
// parameter the written package does not declare cannot take that package's
// Rhs.  What golden does instead — bind the foreign Rhs, leave it bare, or fold
// the read — decides whether the law's map lookup needs a HOME test.
package pf214src;
  parameter int fa214 = 9;
  parameter fb214 = fa214;
endpackage

package pf214;
  import pf214src::*;

  parameter int ga214 = 2;

  function automatic int fsink214(int a, int b);
    return a + b;
  endfunction

  class F214;
    extern function int f_qual214();
    extern function int f_wild214();
    extern function int f_own214();
  endclass

  // EXPLICITLY QUALIFIED foreign read.
  function int F214::f_qual214();
    return fsink214(pf214src::fa214, pf214src::fb214);
  endfunction

  // WILDCARD-IMPORTED foreign read, written bare.
  function int F214::f_wild214();
    return fsink214(fa214, fb214);
  endfunction

  // The package's OWN parameter in the same listing — the law's own cell, as
  // the positive control inside this arm.
  function int F214::f_own214();
    return ga214 + 1;
  endfunction

endpackage

module tope214;
  pf214::F214 f = new();
  int x;
  initial x = f.f_wild214();
endmodule
