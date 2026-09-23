class C;
  struct packed { logic a; logic b; } [1:0] m;
endclass
module dut(input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule
