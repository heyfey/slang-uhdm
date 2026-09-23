interface ifc;
  struct packed { logic a; logic b; } [1:0] d;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.d = i;
  assign o = u.d;
endmodule
