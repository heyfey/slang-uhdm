// § unknownModEmptyNamedConnPort404
module child (input clk_i, input reset_i, output y);
  wire q;
  nosuch s (.clk_i, .reset_i(), .y(q));
endmodule
module top; endmodule
