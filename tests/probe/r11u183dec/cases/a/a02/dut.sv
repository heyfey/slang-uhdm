package p;
   parameter logic [7:0] X = 8'hab;
endpackage
module top(output int a);
   assign a = p::X;
endmodule
