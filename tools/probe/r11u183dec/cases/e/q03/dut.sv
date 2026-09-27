interface bif;
  logic [3:0] read_data;
endinterface
module m(bif bit_field_if);
  genvar i;
  for (i = 0; i < 4; ++i) begin : g
    assign bit_field_if.read_data[i] = 1'b0;
  end
endmodule
module top;
  bif b();
  m u(.bit_field_if(b));
endmodule
