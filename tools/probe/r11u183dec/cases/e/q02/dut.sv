interface bif;
  logic [3:0] read_data;
endinterface
module m(bif bit_field_if);
  assign bit_field_if.read_data[1] = 1'b0;
endmodule
module top;
  bif b();
  m u(.bit_field_if(b));
endmodule
