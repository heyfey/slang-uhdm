module top(output wire o);
  if (1) begin : G
    wire x;
    if (1) begin : H
      wire y;
      assign G.x = 1'b0;
      assign H.y = 1'b1;
      assign G.H.y = 1'b1;
    end
  end
  assign o = G.x;
  assign G.H.y = 1'b0;
endmodule
