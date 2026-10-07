// § tpPackedArrCaUnparent275 — a bit-select left side
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input logic [1:0] i, output T o);
  assign o[0] = i;
  assign o[1] = i;
endmodule
