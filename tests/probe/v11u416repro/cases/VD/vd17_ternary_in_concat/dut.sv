// § defGenConnSelAtIndex416
module sub(input logic [1:0] a, output logic o);
  assign o = a[0];
endmodule
module top(input logic c, input logic [3:0] x, y, output logic [3:0] z);
  for (genvar i = 0; i < 4; i++) begin : g
    sub u (.a({c ? x[i] : y[i], y[0]}), .o(z[i]));
  end
endmodule
