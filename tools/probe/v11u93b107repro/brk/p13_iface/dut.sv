interface ifc;
  struct packed { logic a; logic b; } [1:0] d;
  modport m(input d);
endinterface
module child(ifc.m p, output logic [3:0] o);
  assign o = p.d;
endmodule
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc f();
  assign f.d = i;
  child u(.p(f), .o(o));
endmodule
