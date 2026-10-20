// § defGenConnSelAtIndex416
module sub(input logic [1:0] a, output logic o);
  assign o = a[0];
endmodule
module top(input logic [1:0] m [4], input logic [3:0] y, output logic [3:0] z);
  for (genvar i = 0; i < 4; i++) begin : g
    sub u (.a({|m[i], y[i]}), .o(z[i]));
  end
endmodule
