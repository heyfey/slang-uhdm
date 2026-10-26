// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y;
  logic [3:0] x;
  if (W <= 4) begin: g
    assign y = $bits(x) + $clog2(W);
  end
endmodule
