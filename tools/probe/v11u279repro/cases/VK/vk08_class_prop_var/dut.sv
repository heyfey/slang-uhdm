// § inlineStructPortVarKwSpan279
class c;
  var struct packed { logic [1:0] a; logic b; } x;
endclass
module dut(output logic o);
  c h;
  initial h = new();
  assign o = 1'b0;
endmodule
