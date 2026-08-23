// r10v113 / v113_top.sv — TOPS AND INSTANCES.  Two tops, an import-only module,
// an import-nothing module, and 1..3 instances of a child that carries the
// collision, so the ELAB view walks the same class several times.
package utop;
  function automatic int Girder(int n); return n + 1; endfunction
  class Span;
    function int lift(); return Girder(1); endfunction
    function int Girder(int n); return n + 100; endfunction
    function int drop(); return Girder(2); endfunction
  endclass
endpackage

module child_top #(parameter int ID = 0);
  import utop::*;
  Span s;
  initial begin s = new(); end
endmodule

module tb_top_a;                 // TOP 1: three instances
  child_top #(1) u0 ();
  child_top #(2) u1 ();
  child_top #(3) u2 ();
endmodule

module tb_top_b;                 // TOP 2: imports the package but nothing else
  import utop::*;
  initial begin end
endmodule

module tb_top_c;                 // imports NOTHING
  initial begin end
endmodule
