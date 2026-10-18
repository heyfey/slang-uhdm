// § bitsBlockLocalKeepsCall401
module top;
  int n;
  initial begin
    logic [7:0] v;
    logic [$bits(v)-1:0] w;
    localparam int L = $bits(v);
    n = L + $bits(w);
  end
endmodule
