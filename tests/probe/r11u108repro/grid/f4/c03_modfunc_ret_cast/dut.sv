module dut (input logic [11:0] a, output logic [31:0] o);
  typedef logic signed [31:0] imm_t;
  function automatic imm_t f(logic [11:0] x); f = imm_t'($signed(x)); endfunction
  assign o = f(a);
endmodule
