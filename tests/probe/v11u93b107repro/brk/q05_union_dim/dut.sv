module dut #(parameter type T = union packed { logic [1:0] a; logic [1:0] b; } [1:0]) (input T i, output T o);
  assign o = i;
endmodule
