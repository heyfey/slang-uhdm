// § invalidCaAssignChild404
module child #(parameter p) (input w, input [3:0] c, output [p-1:0] y, output [p-1:0] a, output [p-1:0] b);
  assign y = {p{1'b1}};
  assign {a, b} = {p{c}};
endmodule
module top; endmodule
