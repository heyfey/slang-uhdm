// § tpPackedArrCaUnparent275 — an anonymous packed struct with two dimensions
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0][2:0]) (input T i, output T o);
  assign o = i;
endmodule
