module dut #(parameter type E = logic [1:0], parameter type T = struct packed { E a; logic b; }) (input T i, output T o);
  assign o = i;
endmodule
