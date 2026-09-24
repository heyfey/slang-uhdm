module dut(input logic [3:0] i, input logic c, output logic [3:0] o);
  logic [1:0][1:0] x;
  assign x = i;
  assign o = x;
endmodule
