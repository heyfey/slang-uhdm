// § lvPathBaseAtFirstMember154
`define tie(RIF) \
  for (genvar __i = 0; __i < 2; ++__i) begin : g \
    assign  RIF.read_data[__i]  = 1'b0; \
  end
interface bif; logic [3:0] read_data; endinterface
module m(bif bit_field_if);
  `tie(bit_field_if)
endmodule
module top(); bif b(); m u(b); endmodule
