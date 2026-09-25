// r11u161 gen path CONTROL: module-level cont-assign LHS into a gen scope (not a def-view gen statement)
module top(input logic a, output logic o);
  if (1) begin : A
    wire x;
  end
  assign A.x = a;
  assign o = A.x;
endmodule
