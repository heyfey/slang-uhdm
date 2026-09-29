// § pkgPatFuncBodyLeftoverNoParent227 — read inside an if and a loop
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c;
    c.d = 0;
    if (c.d == 0) c.u = UU;
    for (int i = 0; i < 2; i++) c.d += 32;
    return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam pk::in_t S = P.u;
  assign o = 1'b0;
endmodule
module dut(output logic o);
  kid k0 (.o(o));
endmodule
