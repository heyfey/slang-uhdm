// § pkgPatFuncBodyLeftoverNoParent227 — a function of another package reading pk::UU, called from that package
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
endpackage
package pk2;
  function automatic pk::c_t mk();
    pk::c_t c; c.u = pk::UU; c.d = 64; return c;
  endfunction
  localparam pk::c_t C = mk();
endpackage
module kid #(
    parameter pk::c_t P = pk2::C
) (output logic o);
  localparam pk::in_t S = P.u;
  assign o = 1'b0;
endmodule
module dut(output logic o);
  kid k0 (.o(o));
endmodule
