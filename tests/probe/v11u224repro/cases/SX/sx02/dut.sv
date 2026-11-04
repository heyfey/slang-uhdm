// § strLitPpEscIdShift224
module top(input string s, output int o);
  always_comb begin
    case (s)
      "a\nb` c": o = 1;
      default: o = 0;
    endcase
  end
endmodule
