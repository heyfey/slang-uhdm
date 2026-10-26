// § genCaConstRhsWhole433
module sub #(parameter W = 2) (output [31:0] y, output [7:0] p);
  logic [4:0] x;
  if (W > 1) begin: g
    assign y = W * 2 + 1;
    assign p[3:0] = $bits(x) - W;
  end
endmodule
module top(output [31:0] y0, y1, output [7:0] p0, p1);
  sub #(.W(3)) u0(.y(y0), .p(p0));
  sub #(.W(5)) u1(.y(y1), .p(p1));
endmodule
