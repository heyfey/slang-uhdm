// § macroIfaceRangeSelBaseTok256 (an if-generate scope with the macro select)
`define conn(FIF, LSB) \
  assign  FIF.read_data[LSB+:4] = x;
interface bif; logic [7:0] read_data; endinterface
module m #(parameter bit E = 1)(bif bi); logic [3:0] x;
  if (E) begin : g
    `conn(bi, 4)
  end
endmodule
module top; bif b(); m u(.bi(b)); endmodule
