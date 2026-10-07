// § leftoverTsCopyPerElabUse272
// a port and a net typed by the same struct beside the parameter
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (input pk::c_t i, output pk::c_t o);
  pk::c_t n;
  assign n = i;
  assign o = n ^ P;
endmodule
module dut(input pk::c_t i, output pk::c_t o);
  kid k0 (.i(i), .o(o));
endmodule
