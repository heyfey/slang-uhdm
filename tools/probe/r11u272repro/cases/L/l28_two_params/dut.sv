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
module kid #(parameter pk::c_t P = pk::C, parameter pk::in_t Q = pk::UU) (output logic o);
  assign o = 1'b0;
endmodule
module dut(output logic o);
  kid k0 (.o(o));
endmodule
