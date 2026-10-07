// § leftoverTsCopyPerElabUse272
// (no continuous-assignment read of the parameter) a vector-typed parameter whose default is the package struct
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter logic [95:0] P = pk::C) (output logic [95:0] o);
  localparam int unsigned RD1 = P;
  assign o = '0;
endmodule
module dut(output logic [95:0] o);
  kid k0 (.o(o));
endmodule
