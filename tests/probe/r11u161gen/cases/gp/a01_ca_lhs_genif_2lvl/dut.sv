// r11u161 gen path: cont-assign LHS inside a gen-if block, 2-level scope path (SEL)
module top(output wire o);
  if (1) begin : A
    wire x;
    if (1) begin : B
      wire x;
      assign A.x = 1'b1;
    end
  end
  assign o = A.x;
endmodule
