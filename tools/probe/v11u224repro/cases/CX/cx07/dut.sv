// § strLitContOwnerEnd224
module top(input logic c, output string o);
  always_comb begin
    case (c)
      1'b1: o = "ab \
cd";
      default: o = c ? "e" : "fg \
hi";
    endcase
  end
endmodule
