// § pkgPatFuncBodyLeftoverNoParent227
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
interface ifc #(parameter pk::c_t P = pk::C) ();
  logic [P.u.a-1:0] w;
endinterface
module dut(output logic o);
  ifc i();
  assign o = i.w[0];
endmodule
