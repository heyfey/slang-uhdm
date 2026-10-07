// § leftoverTsCopyPerElabUse272
// a wildcard import in the module header and a bare default
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid import pk::*; #(parameter c_t P = C) (output logic o);
  localparam int unsigned RD = P.d;
  assign o = '0;
endmodule
module dut(output logic o); kid k0 (.o(o)); endmodule
