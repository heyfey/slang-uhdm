// § tpPackedArrCaUnparent275 — CONTROL: no assignment to a signal of the type, the array keeps its parent
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input T i, output logic o);
  always_comb o = ^i;
endmodule
