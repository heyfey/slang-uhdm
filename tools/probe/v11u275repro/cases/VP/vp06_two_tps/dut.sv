// § tpPackedArrCaUnparent275 — two type parameters, one assigned
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0],
             parameter type U = struct packed { logic c; } [2:0]) (input T i, input U j, output T o, output U p);
  assign o = i;
  always_comb p = j;
endmodule
