module child(input logic [3:0] i, output struct packed { logic a; logic b; } [1:0] q);
  assign q = i;
endmodule
module dut(input logic [3:0] i, output logic [3:0] o);
  child u(.i(i), .q(o));
endmodule
