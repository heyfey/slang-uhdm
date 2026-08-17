module \a.b.C #(parameter W = 4) (input wire [W-1:0] x, output wire [W-1:0] y);
  wire [W-1:0] mid;
  wire [2*W-1:0] wide;
  assign mid = x;
  assign y = mid;
  assign wide = {x, x};
endmodule
