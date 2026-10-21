// § arrayElemReplCountFold422
// a replication count written as a localparam expression
module child(input a, output b);
  assign b = a;
endmodule
module top #(parameter W = 8) (input en, output [W/2-1:0] o);
  localparam H = W / 2;
  child c[H-1:0] (.a({(W/2){en}}), .b(o));
endmodule
