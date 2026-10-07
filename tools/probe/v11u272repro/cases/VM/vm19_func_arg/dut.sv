// § leftoverTsCopyPerElabUse272
// (no continuous-assignment read of the parameter) a package function with an argument building the default
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
package pa;
  function automatic pk::c_t mka(int unsigned n);
    pk::c_t c; c.u = pk::UU; c.d = n * 2; return c;
  endfunction
  localparam pk::c_t CA = mka(5);
endpackage
module kid #(parameter pk::c_t P = pa::CA) (output logic [31:0] o);
  localparam int unsigned RD1 = P.d;
  assign o = '0;
endmodule
module dut(output logic [31:0] o);
  kid k0 (.o(o));
endmodule
