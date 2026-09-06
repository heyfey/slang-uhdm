// r10uvm173 arm D — THE CELLS THE LAW MUST NOT TOUCH.  Everything here is a
// call whose callee is NOT a package function reached from that package's own
// DEF listing: module-scope subroutines, a module function calling a package
// function, a class in a package called from a module, a DPI import, and a
// system call.  Every cell must stay byte-identical across the two binaries.
package Prosody_pkg;
  function automatic int unsigned cadence(int unsigned v);
    return v + 5;
  endfunction
  class Meter;
    function int unsigned beat(int unsigned v);
      return cadence(v);
    endfunction
  endclass
endpackage

module prosody_mid (input int unsigned a, output int unsigned y);
  // A MODULE's own function calling a module sibling and a package function.
  function automatic int unsigned localTrim(int unsigned v);
    return v - 1;
  endfunction
  function automatic int unsigned localMix(int unsigned v);
    return localTrim(v) + Prosody_pkg::cadence(v) + $clog2(v + 2);
  endfunction
  assign y = localMix(a);
endmodule

module prosody_top (input int unsigned a, output int unsigned y1, output int unsigned y2);
  import Prosody_pkg::*;
  Meter m;
  int unsigned held;
  prosody_mid u_mid (.a(a), .y(y1));
  initial begin
    m = new();
    held = m.beat(a);
  end
  assign y2 = held + cadence(a);
endmodule
