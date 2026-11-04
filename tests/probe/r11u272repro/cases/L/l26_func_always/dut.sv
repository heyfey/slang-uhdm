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
module kid #(parameter pk::c_t P = pk::C) (input logic clk, output logic [31:0] o);
  function automatic logic [31:0] f(); return P.u.a + P.d; endfunction
  always_ff @(posedge clk) o <= f();
endmodule
module dut(input logic clk, output logic [31:0] o);
  kid k0 (.clk(clk), .o(o));
endmodule
