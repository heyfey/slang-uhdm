// § unknownModEmptyNamedConnPort404
module child #(parameter p) (input x, output y);
  wire [3:0] q;
  nosuch #(.w_p(p)) s (.a(x), .b(), .c(y), .d(q[1]));
endmodule
module child__abstract(); if (0) begin : abstract child not_used(); end endmodule
module top; endmodule
