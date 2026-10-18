// § unknownModEmptyNamedConnPort404
module sub #(parameter w_p = 2) (input a, output [w_p-1:0] b, output c, output [3:0] d);
  assign b = a; assign c = a; assign d = a;
endmodule
module child #(parameter p = 3) (input x, output y);
  sub #(.w_p(p)) s (.a(x), .b(), .c(y), .d());
  sub s2 (.a(x), .b(), .c(), .d());
endmodule
module top; endmodule
