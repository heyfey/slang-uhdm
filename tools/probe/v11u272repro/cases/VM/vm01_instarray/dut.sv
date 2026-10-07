// § leftoverTsCopyPerElabUse272
// (no continuous-assignment read of the parameter) an instance array of the child taking the default
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
  localparam int unsigned RD1 = P.d[0];
  assign o = '0;
endmodule
module dut(output logic [1:0] o);
  kid k[1:0] (.o(o));
endmodule
