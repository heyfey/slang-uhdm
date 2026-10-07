// § inlineStructPortVarKwSpan279
module dut(input logic [2:0] i, output logic [2:0] o);
  always_comb begin
    var struct packed { logic [1:0] a; logic b; } t;
    t = i;
    o = t;
  end
endmodule
