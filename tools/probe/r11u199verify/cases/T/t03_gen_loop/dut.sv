// § caTernFillArmKept193
module m #(parameter bit P = 1) (input logic [7:0] x, output logic [7:0] y [3]);
  for (genvar i = 0; i < 3; i++) begin : g
    assign y[i] = (P) ? '1 : x + 8'(i);
  end
endmodule
module top (input logic [7:0] x, output logic [7:0] a [3], output logic [7:0] b [3]);
  m #(.P(0)) u_a (.x(x), .y(a));
  m #(.P(1)) u_b (.x(x), .y(b));
endmodule
