module dut #(parameter type T = enum logic [1:0] { A, B, C }) (input T i, output T o);
  assign o = i;
endmodule
