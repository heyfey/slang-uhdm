module dut #(parameter type t = int) (input logic s, output t o);
  t x [2];
  assign x[0] = s;
  assign o = x[0];
endmodule
