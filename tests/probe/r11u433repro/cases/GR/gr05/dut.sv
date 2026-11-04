// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, z);
  logic [4:0] x;
  assign z = $clog2(W);
  if (W <= 4) begin: g
    assign y = $clog2(W);
  end
endmodule
