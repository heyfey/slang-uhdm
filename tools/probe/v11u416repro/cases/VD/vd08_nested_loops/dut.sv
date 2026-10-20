// § defGenConnSelAtIndex416
module sub(input logic [1:0] a, output logic o);
  assign o = a[0];
endmodule
module top(input logic [3:0] x, y, output logic [3:0] z [2]);
  for (genvar j = 0; j < 2; j++) begin : gj
    for (genvar i = 0; i < 4; i++) begin : gi
      sub u (.a({x[i], y[j]}), .o(z[j][i]));
    end
  end
endmodule
