// § leftoverTsCopyPerElabUse272
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
  localparam int unsigned AA = UU.a;
endpackage
interface bus; logic v; modport m(output v); endinterface
module kid #(parameter pk::c_t P = pk::C) (bus.m b);
  assign b.v = P.d[0];
endmodule
module dut(output logic o);
  bus b0 ();
  kid k0 (.b(b0));
  assign o = b0.v;
endmodule
