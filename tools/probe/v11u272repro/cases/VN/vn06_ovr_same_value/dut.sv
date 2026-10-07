// § leftoverTsCopyPerElabUse272
// an override with an equal package-qualified value and a second instance with the default
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (output logic o);
  localparam int unsigned RD = P.d;
  assign o = '0;
endmodule
module dut(output logic [1:0] o);
  kid #(pk::C) k0 (.o(o[0]));
  kid k1 (.o(o[1]));
endmodule
