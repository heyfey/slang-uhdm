// § tpPackedArrCaUnparent275 — anonymous packed struct with dimensions, output port assigned
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input T i, output T o);
  assign o = i;
endmodule
