// § tpPackedArrCaUnparent275 — a member-select left side
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input logic i, output T o);
  assign o[0].a = i;
  assign o[0].b = i;
  assign o[1] = '0;
endmodule
