// § defGenConnSelAtIndex416
module sub(input logic [1:0] a, output logic o);
  assign o = a[0];
endmodule
module top #(parameter int P [2] = '{0, 1}) (input logic [3:0] x, y, output logic [3:0] z);
  for (genvar i = 0; i < 2; i++) begin : g
    sub u (.a({x[P[i]], y[i]}), .o(z[i]));
  end
endmodule
