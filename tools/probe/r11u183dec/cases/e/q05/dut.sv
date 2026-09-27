`define tie(RIF) \
  for (genvar i = 0; i < 4; ++i) begin : g \
    assign RIF.read_data[i] = 1'b0; \
  end
interface bif;
  logic [3:0] read_data;
endinterface
module m(bif bit_field_if);
  `tie(bit_field_if)
endmodule
module top;
  bif b();
  m u(.bit_field_if(b));
endmodule
