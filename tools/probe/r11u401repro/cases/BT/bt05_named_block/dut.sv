// § bitsBlockLocalKeepsCall401
module top();
initial begin : blk
  logic [31:0] val;
  $display("%d", $bits(val));
end
endmodule
