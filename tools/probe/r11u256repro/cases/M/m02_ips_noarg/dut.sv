// § macroIfaceRangeSelBaseTok256 (the whole path written in the macro body, no actual)
`define conn \
  assign  bif_p.read_data[2+:4] = x;
interface bif; logic [7:0] read_data; endinterface
module m(bif bif_p); logic [3:0] x;
  `conn
endmodule
module top; bif b(); m u(.bif_p(b)); endmodule
