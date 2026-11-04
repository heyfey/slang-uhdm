// § genBodyBitsOuterNameKeeps429
module sub #(parameter W = 4) (output logic [7:0] y);
  logic [W-1:0] x;
  if (1) begin: g
    always_comb y = $bits(x);
  end
endmodule
module top (output logic [7:0] y1, y2);
  sub #(.W(6)) u1 (.y(y1));
  sub u2 (.y(y2));
endmodule
