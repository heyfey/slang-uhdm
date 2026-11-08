// § enumCastChainKeepsInnerCast493
module top(input int a, input int s, output int v);
  always_comb begin
    case (s)
      int'(int'(a)): v = 1;
      default: v = 0;
    endcase
  end
endmodule
