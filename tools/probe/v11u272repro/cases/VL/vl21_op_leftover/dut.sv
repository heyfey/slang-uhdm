// § leftoverTsCopyPerElabUse272
// an operation over constants as a leftover, a signed member and an enum member
package pk;
  typedef enum logic [1:0] { EA = 2'd1, EB = 2'd2 } e_t;
  typedef struct packed { int signed s; e_t e; logic [5:0] w; } c_t;
  localparam int K1 = 7;
  function automatic c_t mk();
    c_t c; c.s = -3 * 2; c.e = EB; c.w = K1 + 1; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (output logic [31:0] o);
  assign o = P.s + P.w + P.e;
endmodule
module dut(output logic [31:0] o);
  kid k0 (.o(o));
endmodule
