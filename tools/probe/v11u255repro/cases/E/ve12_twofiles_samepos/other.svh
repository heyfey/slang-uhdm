module hmac2 (output hp::hw2reg_t hw2reg);
  for (genvar i = 0; i < 8; i++) begin : g
    assign hw2reg.key[6-i/2].d = '0;
  end
endmodule
