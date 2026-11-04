// § tpPackedArrCaUnparent275 — control: an always_comb assignment only
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input T i, output T o);
  always_comb o = i;
endmodule
