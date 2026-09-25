// r11u161 gen path: cont-assign LHS inside a gen-if block, 3-level scope path (SEL)
module top(output wire o);
  if (1) begin : A
    if (1) begin : B
      wire x;
      if (1) begin : C
        wire y;
        assign A.B.x = 1'b0;
      end
      assign B.C.y = 1'b1;
    end
  end
  assign o = A.B.x;
endmodule
