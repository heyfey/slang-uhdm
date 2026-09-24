module dut #(parameter type T = struct packed signed { logic a; logic b; }) (input T i, output T o);
  assign o = i;
endmodule
