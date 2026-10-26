// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y1, y2, y3, y4, y5, y6;
  if (W <= 4) begin: g
    assign y1 = -1;
    assign y2 = ~0;
    assign y3 = 'hFF;
    assign y4 = 8'd5 + W;
    assign y5 = '1;
    assign y6 = -W + 8'd1;
  end
endmodule
