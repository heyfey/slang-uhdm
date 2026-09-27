// § macroIfacePathTokSpans183 with § hpIdxCallNameSpan184
`define tie(RIF) \
    assign RIF.read_data[f(1)] = 1'b0;
interface bif;
  logic [3:0] read_data;
endinterface
module m(bif bit_field_if);
  function automatic int f(int k); return k; endfunction
  `tie(bit_field_if)
endmodule
module top;
  bif b();
  m u(.bit_field_if(b));
endmodule
