// § defGenConnSelAtIndex416
module sub(input logic [1:0] a, output logic o);
  assign o = a[0];
endmodule
module top(input logic [3:0] x, y, output logic z);
  sub u (.a({x[1], y[2]}), .o(z));
endmodule
