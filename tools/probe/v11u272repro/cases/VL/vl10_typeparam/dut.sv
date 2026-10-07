// § leftoverTsCopyPerElabUse272
// a type parameter typing the struct parameter
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter type T = pk::c_t, parameter T P = pk::C) (output logic [31:0] o);
  assign o = P.d;
endmodule
module dut(output logic [31:0] o);
  kid k0 (.o(o));
endmodule
