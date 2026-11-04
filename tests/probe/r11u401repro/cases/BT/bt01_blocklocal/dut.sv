// § bitsBlockLocalKeepsCall401
module top();
initial begin
  logic [31:0] val;
  $display("%d", $bits(val));
end
endmodule
