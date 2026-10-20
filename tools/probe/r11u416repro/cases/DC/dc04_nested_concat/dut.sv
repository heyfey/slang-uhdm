// § defGenConnSelAtIndex416
module sub(input logic [3:0] a, output logic o);
  assign o = a[0];
endmodule
module top(input logic [3:0] x, y, output logic [3:0] z);
  for (genvar i = 0; i < 4; i++) begin : g
    sub u (.a({x[i], {y[i], x[0]}, y[3]}), .o(z[i]));
  end
endmodule
