// v226 b10 — DEF vs ELAB reachability.  An interface instantiated ONLY inside
// a module that itself is never instantiated: is `defAllInstCount > 0`?  Two
// answers are possible and the law must match golden either way.
interface bx_if;
  logic a;
  int   q;
  initial q = 1;
  always_comb a = q[0];
endinterface

module bx_holder_uninst;          // nothing instantiates THIS
  bx_if u();
endmodule

// A second interface instantiated only inside an uninstantiated INTERFACE.
interface by_if;
  logic a;
  int   q;
  initial q = 2;
endinterface

interface by_holder_uninst;
  by_if v();
endinterface

// A third instantiated inside a generate branch that is NOT taken.
interface bz_if;
  int q;
  initial q = 3;
endinterface

module bz_top;
  parameter int G = 0;
  if (G == 1) begin : on
    bz_if w();
  end
endmodule

module bz_real;
  bz_top #(.G(0)) t();
endmodule
