module dut #(parameter type T = logic [7:0]) (input T i [2], output T o [2]);
  assign o = i;
endmodule
