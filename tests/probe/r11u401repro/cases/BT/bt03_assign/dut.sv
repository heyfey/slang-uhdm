// § bitsBlockLocalKeepsCall401
module top();
int x;
initial begin
  logic [15:0] v;
  x = $bits(v);
end
endmodule
