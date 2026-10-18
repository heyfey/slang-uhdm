// § bitsBlockLocalKeepsCall401
module top;
  int n;
  initial begin logic [3:0] arr [2]; int q[$]; n = $bits(arr); n = $bits(arr[0]); end
endmodule
