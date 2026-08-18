
module top;
  wire o;
  if (1) begin : g
    localparam bit IV = 1'b1;
    and a1(o, IV, 1'b0);
  end
endmodule
