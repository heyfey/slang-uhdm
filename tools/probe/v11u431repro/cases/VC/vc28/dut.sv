// § connReplCountUnparented431v
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module sub #(parameter N = 2) (input en, output [1:0] w);
child c0(.a({N{en}}), .b(w[0]));
child c1(.a({(N+1){en}}), .b(w[1]));
endmodule
module top(input en, output [1:0] w); sub u(.en(en), .w(w)); endmodule
