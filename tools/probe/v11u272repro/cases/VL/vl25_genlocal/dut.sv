// § leftoverTsCopyPerElabUse272
// a generate-scope localparam from the struct parameter
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (output logic [31:0] o);
  for (genvar i = 0; i < 1; i++) begin : g
    localparam pk::c_t G = P;
    localparam pk::c_t H = pk::C;
    assign o = G.d + H.u.a;
  end
endmodule
module dut(output logic [31:0] o);
  kid k0 (.o(o));
endmodule
