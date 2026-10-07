// § leftoverTsCopyPerElabUse272
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  function automatic c_t mk();
    c_t c; c.u.a = 3; c.u.b = 4; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (output logic o);
  assign o = 1'b0;
endmodule
module dut(output logic o);
  kid k0 (.o(o));
endmodule
