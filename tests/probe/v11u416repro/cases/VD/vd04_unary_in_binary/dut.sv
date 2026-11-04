// § defGenConnSelAtIndex416
module sub(input logic a, output logic o);
  assign o = a;
endmodule
module top(input logic [3:0] x, y, output logic [3:0] z);
  for (genvar i = 0; i < 4; i++) begin : g
    sub u (.a(y[i] & ~x[i]), .o(z[i]));
  end
endmodule
