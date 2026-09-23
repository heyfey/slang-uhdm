interface ifc;
  struct packed { logic a; logic b; } [1:0] x;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.x = i;
  assign o = u.x;
endmodule
