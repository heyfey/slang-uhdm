// § tpPackedArrCaUnparent275 — an override from the parent
module child #(parameter type T = logic [3:0]) (input T i, output T o);
  assign o = i;
endmodule
module dut (input logic [3:0] i, output logic [3:0] o);
  child #(.T(struct packed { logic a; logic b; } [1:0])) u (.i(i), .o(o));
endmodule
