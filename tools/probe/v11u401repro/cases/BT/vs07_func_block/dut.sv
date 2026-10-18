// § bitsBlockLocalKeepsCall401
module top;
  function int f();
    begin : b logic [5:0] v; return $bits(v); end
  endfunction
  int n;
  initial begin for (int i = 0; i < 2; i++) begin logic [2:0] u; n = $bits(u) + $bits(i); end end
endmodule
