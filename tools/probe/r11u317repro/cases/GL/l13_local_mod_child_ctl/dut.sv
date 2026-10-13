// § genIfaceInnerLocalKeepsBind317
module child (input logic clk, output logic q);
  assign q = clk;
endmodule
module top (input logic a, output logic o);
  if (1) begin : g
    logic l;
    assign l = ~a;
    child c (.clk(l & a), .q(o));
  end
endmodule
