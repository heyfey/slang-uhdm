module dut(input logic [3:0] i, output struct packed { logic a; logic b; } [1:0] o);
  assign o = i;
endmodule
