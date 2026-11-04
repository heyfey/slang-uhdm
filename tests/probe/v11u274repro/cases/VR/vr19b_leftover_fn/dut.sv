// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (output logic [31:0] o, output logic [31:0] o2);
  always_comb o = P.u.a;
  always_comb o2 = P.u.b + P.d;
endmodule
module dut(output logic [31:0] o, output logic [31:0] o2, output logic [31:0] o3, output logic [31:0] o4);
  kid k0 (.o(o), .o2(o2));
  kid #(.P(pk::C)) k1 (.o(o3), .o2(o4));
endmodule
