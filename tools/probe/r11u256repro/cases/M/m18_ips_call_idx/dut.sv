// § macroIfaceRangeSelBaseTok256 (a call as the base of the select, macro body)
`define conn(FIF) \
  assign  FIF.read_data[f(1)+:4] = x;
interface bif; logic [7:0] read_data; endinterface
module m(bif bi); logic [3:0] x;
  function automatic int f(int a); return a*2; endfunction
  `conn(bi)
endmodule
module top; bif b(); m u(.bi(b)); endmodule
