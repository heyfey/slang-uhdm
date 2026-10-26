// § connReplCountUnparented431v
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module sub(input [7:0] x, output w);
localparam P = 2;
child c(.a({P{x[1:0]}}), .b(w));
endmodule
module top(input [7:0] x, output w); sub u(.x(x), .w(w)); endmodule
