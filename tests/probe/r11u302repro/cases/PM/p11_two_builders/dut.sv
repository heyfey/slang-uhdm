// § modPatLeftoverCloneNoParent302
// p11: two module builders read the same module pattern, and a child gets the result
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  typedef struct packed { in_t v; int unsigned e; } g_t;
endpackage
module kid #(parameter pk::c_t CFG = '{u: '{a: 0, b: 0}, d: 0}) (output logic o);
  localparam pk::in_t S = CFG.u;
  assign o = 1'b0;
endmodule
module dut(output logic o);
  localparam pk::in_t UU = '{a: 2, b: 3};
  function automatic pk::c_t mkA();
    pk::c_t c; c.u = UU; c.d = 1; return c;
  endfunction
  function automatic pk::g_t mkB();
    pk::g_t g; g.v = UU; g.e = 2; return g;
  endfunction
  localparam pk::c_t LA = mkA();
  localparam pk::g_t LB = mkB();
  kid #(.CFG(LA)) k0 (.o(o));
endmodule
