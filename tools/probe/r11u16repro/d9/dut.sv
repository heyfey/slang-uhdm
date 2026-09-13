// d9 — THE VIEW MATRIX.  One child instantiated TWICE with different overrides
// of the same function-built struct parameter, and a grandchild re-pass: the
// def listing (uhdmallModules) must keep the symbolic hier_path while every
// ELABORATED copy folds to its own instance's member bits.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build(int unsigned k);
    cfg_t r;
    r.n    = k;
    r.base = 64'h1000;
    return r;
  endfunction
endpackage

module leaf #(parameter p::cfg_t C = p::build(1)) (output logic [31:0] o);
  assign o = C.n;
endmodule

module mid #(parameter p::cfg_t C = p::build(1)) (output logic [31:0] o, output logic [31:0] o2);
  assign o2 = C.n;
  leaf #(.C(C)) u_l (.o(o));
endmodule

module dut (output logic [31:0] a, output logic [31:0] b,
            output logic [31:0] c, output logic [31:0] d);
  mid #(.C(p::build(3))) u0 (.o(a), .o2(b));
  mid #(.C(p::build(5))) u1 (.o(c), .o2(d));
endmodule
