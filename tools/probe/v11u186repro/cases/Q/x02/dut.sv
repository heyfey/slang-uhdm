// § macroPathTokSpans183 (a multi-line macro, the path in the body, an argument index expression)
`define PICK(IF, LSB, W) \
   IF.data[LSB +: W]
interface bus_if; logic [7:0] data; endinterface
module top(output logic [3:0] o);
  bus_if b();
  if (1) begin : g
    assign o = `PICK(b, 2, 4);
  end
endmodule
