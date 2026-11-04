// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, output [3:0] y4, output [7:0] p);
  logic [4:0] x;
  logic [31:0] v;
  int iv;
  if (W <= 4) begin: g
    assign y = W << 2;
    assign y4 = W << 2;
    assign v = W << 2;
    assign iv = W << 2;
    assign p[1] = W << 2;
    assign p[7:4] = W << 2;
  end
endmodule
