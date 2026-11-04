// § leftoverTsCopyPerElabUse272
// assign o = P with the default a package name
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (output pk::c_t o, output logic [95:0] v);
  assign o = P;
  assign v = P;
endmodule
module dut(output pk::c_t o, output logic [95:0] v);
  kid k0 (.o(o), .v(v));
endmodule
