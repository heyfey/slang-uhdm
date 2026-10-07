// § leftoverTsCopyPerElabUse272
// (no continuous-assignment read of the parameter) an unpacked struct parameter built by a function
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
package pu;
  typedef struct { int unsigned a; int unsigned b; } ui_t;
  function automatic ui_t mku();
    ui_t x; x.a = 3; x.b = 4; return x;
  endfunction
  localparam ui_t U = mku();
endpackage
module kid #(parameter pu::ui_t P = pu::U) (output logic [31:0] o);
  localparam int unsigned RD1 = P.a + P.b;
  assign o = '0;
endmodule
module dut(output logic [31:0] o);
  kid k0 (.o(o));
endmodule
