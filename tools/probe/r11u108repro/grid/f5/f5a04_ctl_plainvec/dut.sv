module dut #(parameter type T = logic [7:0]) (input logic [7:0] a, output T o);
  T x;
  assign x = a;
  assign o = x;
endmodule
