// § leftoverTsCopyPerElabUse272
// a package parameter that names another package parameter as the default
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
package pq;
  localparam pk::c_t C2 = pk::C;
endpackage
module kid #(parameter pk::c_t P = pq::C2) (output logic o);
  localparam int unsigned RD = P.d;
  assign o = '0;
endmodule
module dut(output logic o); kid k0 (.o(o)); endmodule
