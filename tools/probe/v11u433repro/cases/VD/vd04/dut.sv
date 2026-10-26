// § genCaConstRhsWhole433
module top #(parameter W = 2, parameter D = 1) (output [31:0] y);
  if (W <= 4) begin: g
    assign #D y = 5;
  end
endmodule
