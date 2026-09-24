// r10v107 arm b12 — ZERO TOPS.  MEASUREMENT ONLY.  The package alone, no module
// at all: nothing hoists, so the reference must end with NO actual on both
// sides.  (The `!bind5` branch clears the binding unconditionally; the wire is
// minted only by a module that hoists.)
package pb12;
  class d12; int fld; endclass
  class snk12; function int ask(d12 v); return 0; endfunction endclass
  class c12 #(type T = d12);
    snk12 s;
    d12   plain;
    extern function void oob_recvexpr();
    extern function void oob_asg();
  endclass
  function void c12::oob_recvexpr();
    T v12;
    if (s.ask(v12) == 0) begin
    end
  endfunction
  function void c12::oob_asg();
    T w12;
    w12 = plain;
  endfunction
endpackage
