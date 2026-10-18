// § bitsBlockLocalKeepsCall401
module top;
  int n;
  logic [4:0] modv;
  initial begin logic [9:0] v; begin n = $bits(v) + $bits(modv); end end
endmodule
