// § tpPackedArrCaUnparent275 — a net declaration assignment
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input logic [3:0] i, output logic [3:0] o);
  wire T w = i;
  assign o = w;
endmodule
