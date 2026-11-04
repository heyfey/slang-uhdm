// § bitsBlockLocalKeepsCall401
module top;
  int n, m;
  initial fork logic [7:0] w; n = $bits(w); join
  always_comb begin logic [2:0] q; m = $bits(q); end
endmodule
