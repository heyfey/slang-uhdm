// § leftoverTsCopyPerElabUse272
// (no continuous-assignment read of the parameter) a child two for-generate levels down
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
  localparam int unsigned RD1 = P.u.a[0];
  assign o = '0;
endmodule
module dut(output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : g1
    for (genvar j = 0; j < 2; j++) begin : g2
      kid k (.o(o[i*2+j]));
    end
  end
endmodule
