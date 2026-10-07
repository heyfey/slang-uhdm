// § leftoverTsCopyPerElabUse272
// a body localparam with the package default and a parameter port without one
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter int W = 3) (output logic o);
  localparam pk::c_t P = pk::C;
  localparam int unsigned RD = P.d + W;
  assign o = '0;
endmodule
module dut(output logic o); kid k0 (.o(o)); endmodule
