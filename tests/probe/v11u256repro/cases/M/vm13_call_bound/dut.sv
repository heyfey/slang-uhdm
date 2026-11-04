// § macroIfaceRangeSelBaseTok256 (a function call in the select base)
`define conn(FIF) \
  assign FIF.read_data[f(1)+:4] = x;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  function automatic int f(int k); return k*2; endfunction
  `conn(bit_field_if)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule
