// § forceIsForceObj401
module sub(input logic i, output logic o); assign o = i; endmodule
module top;
  logic a, b;
  sub u(.i(a), .o(b));
  initial begin force u.o = 1'b0; #5 release u.o; force b = (a); end
endmodule
