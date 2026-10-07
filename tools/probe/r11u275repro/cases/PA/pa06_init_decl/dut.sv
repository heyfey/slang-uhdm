// § tpPackedArrCaUnparent275 — a declaration with an initializer writes the reset
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0]) (output logic [3:0] o);
  T x = '0;
  assign o = x;
endmodule
