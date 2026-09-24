module inner #(parameter type T = logic) (input T [3:0] a, output T [3:0] b);
  assign b = ~a;
endmodule
module top (input logic [3:0] a, output logic [3:0] b);
  inner u (.a(a), .b(b));
endmodule
