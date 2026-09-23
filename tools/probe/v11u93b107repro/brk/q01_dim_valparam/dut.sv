module dut #(parameter int N = 2, parameter type T = struct packed { logic a; logic b; } [N-1:0]) (input T i, output T o);
  assign o = i;
endmodule
