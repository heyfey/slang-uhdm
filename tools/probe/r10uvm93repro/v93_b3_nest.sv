// v93 B3 — nested streams + an inner shift that the raw-text scan can trip on.
module b3_nest;
  logic [63:0] v, r;
  int k;
  initial begin
    r = { << int { { >> byte { v } } } };
    r = { >> byte { v << 2 } };
    r = { >> 8 { v << k } };
    r = { << int { v[7:0], v[15:8] } };
  end
endmodule
