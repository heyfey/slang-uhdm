// § leftoverTsCopyPerElabUse272
// an untyped parameter with the package default
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter P = pk::C) (output logic o);
  localparam int unsigned RD = P[31:0];
  assign o = '0;
endmodule
module dut(output logic o); kid k0 (.o(o)); endmodule
