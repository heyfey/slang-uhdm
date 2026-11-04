// § macroIfaceRangeSelBaseTok256 (inside a for-generate with a genvar base, macro body)
`define conn(FIF, LSB, WIDTH, V) \
  assign  FIF.read_data[LSB+:WIDTH] = V;
interface bif; logic [7:0] read_data; endinterface
module m(bif bi); logic [1:0] x [4];
  for (genvar g = 0; g < 4; g++) begin : gl
    `conn(bi, g*2, 2, x[g])
  end
endmodule
module top; bif b(); m u(.bi(b)); endmodule
