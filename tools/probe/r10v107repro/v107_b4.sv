// r10v107 arm b4 — TOP MULTIPLICITY.  MEASUREMENT ONLY.  Two tops, one child
// instance, a module that only IMPORTS the package and one that also
// INSTANTIATES its classes, and one module that imports nothing.  The wire is
// minted ONCE PER REFERENCE in golden (R-MULTI); this arm measures whether the
// patch widens that residue beyond what the PRISTINE binary already does.
package pb4;
  class d4;
    int fld;
  endclass
  class snk4;
    function int ask(d4 v); return 0; endfunction
  endclass
  class c4 #(type T = d4);
    snk4 s;
    d4   plain;
    extern function void oob_recvexpr();
  endclass
  function void c4::oob_recvexpr();
    T vb4;
    if (s.ask(vb4) == 0) begin
    end
  endfunction
endpackage

module childb4;
  import pb4::*;
  c4 #(d4) ci;
  initial ci = new();
endmodule

module topb4_a;          // TOP 1 — imports and instantiates
  import pb4::*;
  c4 #(d4) ai;
  childb4 kid();
  initial ai = new();
endmodule

module topb4_b;          // TOP 2 — imports only, no class instance
  import pb4::*;
  logic q;
  initial q = 1'b0;
endmodule

module topb4_c;          // imports NOTHING
  logic r;
  initial r = 1'b1;
endmodule
