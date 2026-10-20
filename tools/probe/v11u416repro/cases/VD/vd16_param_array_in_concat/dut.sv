// § defGenConnSelAtIndex416
module sub(input logic [1:0] a, output logic o);
  assign o = a[0];
endmodule
module top #(parameter logic [3:0] P = 4'b1010) (input logic [3:0] y, output logic [3:0] z);
  for (genvar i = 0; i < 4; i++) begin : g
    sub u (.a({P[i], y[i]}), .o(z[i]));
  end
endmodule
