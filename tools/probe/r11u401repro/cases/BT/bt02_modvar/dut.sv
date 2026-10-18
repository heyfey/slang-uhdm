// § bitsBlockLocalKeepsCall401
module top();
logic [31:0] val;
initial begin
  $display("%d", $bits(val));
end
endmodule
