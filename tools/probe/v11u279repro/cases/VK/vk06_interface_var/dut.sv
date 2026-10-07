// § inlineStructPortVarKwSpan279
interface ifc;
  var struct packed { logic [1:0] a; logic b; } s;
endinterface
module dut(output logic [2:0] o);
  ifc u();
  assign o = u.s;
endmodule
