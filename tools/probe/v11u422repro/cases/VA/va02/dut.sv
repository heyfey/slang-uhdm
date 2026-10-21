// § arrayElemConcatConnWhole422
// part-select operands and a nested replication
module child(input [1:0] a, output [1:0] b);
  assign b = a;
endmodule
module top(input [7:0] bus, input e, output [7:0] o);
  child c[3:0] (.a({bus[7:4], {2{e, e}}}), .b(o));
endmodule
