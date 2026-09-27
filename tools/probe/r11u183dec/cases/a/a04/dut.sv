package p;
   typedef logic [7:0] t;
   parameter t X = 8'hab;
endpackage
module top(output int a);
   assign a = p::X;
endmodule
