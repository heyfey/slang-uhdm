// § inlineStructPortVarKwSpan279
module dut(output logic [2:0] o);
  task automatic t(output logic [2:0] r);
    static var struct packed { logic [1:0] a; logic b; } s = 3'b101;
    r = s;
  endtask
  initial t(o);
endmodule
