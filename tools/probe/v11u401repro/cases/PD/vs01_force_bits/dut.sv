// § forceIsForceObj401
module top;
  wire [3:0] w; logic [3:0] r;
  initial begin force w[1] = 1'b1; force r = w + 1; #1 release w[1]; release r; end
endmodule
