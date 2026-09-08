// r10v215 ADVERSARIAL ARM v8 — THE InterfaceModPort CANARY'S OWN SHAPE plus
// every mixture that must KEEP its object, in one design, so a law that over-
// reaches shows up beside the cells it is allowed to move.
//   m1  `modport MEM (clocking cb, input clock)`  — the canary's literal shape
//   m2  `modport (import t, input a)`             — tf + simple
//   m3  `modport (export f, output b)`            — export + simple
//   m4  `modport (clocking cb, import t)`         — BOTH non-simple kinds: drops
//   m5  `modport (ref r)`                         — § modportRefDirInout
//   m6  `modport (input .P(x[1:0]))`              — § modportExprPort
interface v8_if;
  logic clock;
  logic frame;
  logic a;
  logic b;
  logic r;
  logic [3:0] x;
  clocking cb @(posedge clock);
    inout frame;
  endclocking
  task automatic t(input logic v);
  endtask
  function automatic int f();
    return 0;
  endfunction
  modport MEM (clocking cb, input clock);
  modport m2 (import t, input a);
  modport m3 (export f, output b);
  modport m4 (clocking cb, import t);
  modport m5 (ref r);
  modport m6 (input .P(x[1:0]));
endinterface

module v8_sub (v8_if.MEM p);
endmodule

module top;
  v8_if i1();
  v8_sub s1(i1);
endmodule
