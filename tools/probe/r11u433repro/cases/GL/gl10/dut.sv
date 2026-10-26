// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, output [3:0] y4, output [7:0] p);
  logic [4:0] x;
  logic [31:0] v;
  int iv;
  if (W <= 4) begin: g
    assign y = $clog2(W) + 1;
    assign y4 = $clog2(W) + 1;
    assign v = $clog2(W) + 1;
    assign iv = $clog2(W) + 1;
    assign p[1] = $clog2(W) + 1;
    assign p[7:4] = $clog2(W) + 1;
  end
endmodule
