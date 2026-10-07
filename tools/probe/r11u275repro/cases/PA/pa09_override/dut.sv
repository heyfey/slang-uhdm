// § tpPackedArrCaUnparent275 — the type overridden by the parent with another anonymous array
module child #(parameter type T = logic) (input T i, output T o);
  assign o = i;
endmodule
module dut (input logic [5:0] i, output logic [5:0] o);
  child #(.T(struct packed { logic [1:0] a; logic b; } [1:0])) u (.i(i), .o(o));
endmodule
