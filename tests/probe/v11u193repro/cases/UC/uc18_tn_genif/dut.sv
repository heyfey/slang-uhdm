// § caUnsizedRhsClonePerInst193
module m #(parameter bit P = 1, parameter bit G = 1) (input logic [7:0] x, output logic [7:0] y);
  if (G) begin : g
    assign y[3:0] = (P) ? x[3:0] : '0;
  end
endmodule
module top (input logic [7:0] x, output logic [7:0] y);
  m #(.P(0)) u_a (.x(x), .y(y));
endmodule
