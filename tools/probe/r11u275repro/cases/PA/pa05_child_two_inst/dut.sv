// § tpPackedArrCaUnparent275 — a child instantiated twice, both instances assign the port
module child #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input T i, output T o);
  assign o = i;
endmodule
module dut (input logic [3:0] i, output logic [3:0] o1, o2);
  child u1 (.i(i), .o(o1));
  child u2 (.i(i), .o(o2));
endmodule
