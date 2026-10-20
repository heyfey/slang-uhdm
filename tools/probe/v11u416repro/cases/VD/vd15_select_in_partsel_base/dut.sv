// § defGenConnSelAtIndex416
module sub(input logic [1:0] a, output logic o);
  assign o = a[0];
endmodule
module top(input logic [3:0] x, input logic [1:0] y [4], output logic [3:0] z);
  for (genvar i = 0; i < 4; i++) begin : g
    sub u (.a({x[y[i] +: 1], x[0]}), .o(z[i]));
  end
endmodule
