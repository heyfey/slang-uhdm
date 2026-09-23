module dut(input logic [3:0] i, output logic [3:0] o);
  union packed { struct packed { logic a; logic b; } s; logic [1:0] v; } [1:0] x;
  assign x = i;
  assign o = x;
endmodule
