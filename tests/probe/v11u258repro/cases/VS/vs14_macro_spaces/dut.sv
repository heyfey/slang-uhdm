// § lvStreamBaseKeepsActual258 (a macro body streaming target written with spaces around the path's dots and select)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; logic [1:0][3:0] d; endinterface
`define WR(FIF, X) always_comb {>>{ FIF . read_data [3:0] }} = X;
module m(bif bit_field_if); logic [3:0] x;
  `WR(bit_field_if, x)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule
