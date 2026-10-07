// § inlineStructPortVarKwSpan279
package p;
  var struct packed { logic [1:0] a; logic b; } pv;
endpackage
module dut(output logic [2:0] o);
  assign o = p::pv;
endmodule
