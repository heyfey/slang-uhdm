// § unknownModBitSelConnScope404
module sub #(parameter w_p = 1) (input a, output b, output c, input d);
  assign b = a; assign c = d;
endmodule
module child #(parameter p) (input x, output y);
  wire [3:0] q;
  sub #(.w_p(p)) s (.a(x), .b(), .c(y), .d(q[1]));
endmodule
module child2 #(parameter p = 1) (input x, output y);
  wire [3:0] q;
  nosuch #(.w_p(p)) s (.a(x), .b(), .c(y), .d(q[1]));
endmodule
module child__abstract(); if (0) begin : abstract child not_used(); end endmodule
module top; endmodule
