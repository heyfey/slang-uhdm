// § defNetTypeParamPackedDim144
module dut #(parameter type dtype = struct packed { logic [1:0] a; logic b; }) (input logic clk, output logic [2:0] o);
  dtype [1:0][2:0] mem;
  always_ff @(posedge clk) mem <= '0;
  assign o = mem[0][0];
endmodule
