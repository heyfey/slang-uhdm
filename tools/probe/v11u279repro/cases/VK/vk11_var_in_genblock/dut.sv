// § inlineStructPortVarKwSpan279
module dut(input logic [2:0] i, output logic [2:0] o);
  if (1) begin : g
    var struct packed { logic [1:0] a; logic b; } x;
    assign x = i;
  end
  assign o = g.x;
endmodule
