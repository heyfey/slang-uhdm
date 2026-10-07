// § leftoverTsCopyPerElabUse272
// (no continuous-assignment read of the parameter) a child at instance depth 3
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
  localparam int unsigned RD1 = P.d[6];
  assign o = '0;
endmodule
module mid2(output logic o); kid k (.o(o)); endmodule
module mid1(output logic o); mid2 m2 (.o(o)); endmodule
module dut(output logic o);
  mid1 m1 (.o(o));
endmodule
