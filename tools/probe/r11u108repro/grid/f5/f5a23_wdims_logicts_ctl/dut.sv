module dut #(parameter type T = logic [1:0]) (input logic [7:0] a, output logic [7:0] o);
  T [3:0] x;
  assign x = a;
  assign o = x;
endmodule
