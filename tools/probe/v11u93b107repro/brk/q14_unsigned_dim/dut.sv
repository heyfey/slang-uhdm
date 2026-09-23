module dut #(parameter type T = struct packed unsigned { logic a; logic b; } [1:0]) (input T i, output T o);
  assign o = i;
endmodule
