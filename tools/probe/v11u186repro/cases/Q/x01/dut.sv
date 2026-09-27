// § macroPathTokSpans183 (a macro path in a definition-view generate scope, argument base, member bit select)
`define RD(IF, I) IF.data[I]
interface bus_if; logic [3:0] data; endinterface
module top(output logic [1:0] o);
  bus_if b();
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = `RD(b, 1);
  end
endmodule
