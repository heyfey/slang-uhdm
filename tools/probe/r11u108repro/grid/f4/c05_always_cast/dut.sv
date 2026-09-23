module dut (input logic [11:0] a, output logic [31:0] o);
  typedef logic signed [31:0] imm_t;
  always_comb o = imm_t'($signed(a));
endmodule
