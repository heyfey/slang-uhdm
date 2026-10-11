// § genCaSelBoundUnsizedClone282
module m #(parameter int unsigned S = 4, parameter int D = 1) (input logic [1:0] c, input logic [7:0] x, output logic [7:0] y6 [2], output logic [7:0] zz, output logic yo);
  struct packed { logic [7:0] addr; } st;
  assign st.addr = x;
  if (1) begin : gb
    assign y6[0] = c[0] ? '0 : x[S:0];
  end
endmodule
module top(input logic [1:0] c, input logic [7:0] x, output logic [7:0] y6 [2], output logic [7:0] zz, output logic yo); m u(.c(c), .x(x), .y6(y6), .zz(zz), .yo(yo)); endmodule
