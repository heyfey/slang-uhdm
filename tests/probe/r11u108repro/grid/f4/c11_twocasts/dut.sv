module dut (input logic [11:0] a, output logic [31:0] o, output logic [31:0] p);
  typedef logic signed [31:0] imm_t;
  function automatic logic [31:0] f(logic [11:0] x); f = imm_t'($signed(x)); endfunction
  function automatic logic [31:0] g(logic [11:0] x); g = imm_t'($signed(x)); endfunction
  assign o = f(a);
  assign p = g(a);
endmodule
