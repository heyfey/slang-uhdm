module dut (input logic [11:0] a, output logic [31:0] o);
  typedef logic signed [31:0] imm_t;
  task automatic t(input logic [11:0] x, output logic [31:0] y); y = imm_t'($signed(x)); endtask
  always_comb t(a, o);
endmodule
