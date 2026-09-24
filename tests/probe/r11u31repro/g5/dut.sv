module dut #(parameter type T = struct packed { logic [1:0] a; logic b; } [3:0]) (output T o); assign o = '0; endmodule
