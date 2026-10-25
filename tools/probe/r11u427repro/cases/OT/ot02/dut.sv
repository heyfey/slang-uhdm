// § ovUntypedTsDeclWidth427
module sub #(parameter A = 1'b0, parameter B = 4'b0, parameter C = 8, parameter D = 'h7, parameter E = 4'd3, parameter F = 8'hFF, parameter G = 2 + 1)(input a, output o);
  assign o = a ^ A[0] ^ B[0] ^ C[0] ^ D[0] ^ E[0] ^ F[0] ^ G[0];
endmodule
module top(input a, output [7:0] o);
  localparam K = 6'd9;
  sub #(.A(16'hABCD)) uA(.a(a), .o(o[0]));
  sub #(.B(16'hABCD)) uB(.a(a), .o(o[1]));
  sub #(.C(16'hABCD)) uC(.a(a), .o(o[2]));
  sub #(.D(16'hABCD)) uD(.a(a), .o(o[3]));
  sub #(.E(16'hABCD)) uE(.a(a), .o(o[4]));
  sub #(.F(16'hABCD)) uF(.a(a), .o(o[5]));
  sub #(.G(16'hABCD)) uG(.a(a), .o(o[6]));
  sub u0(.a(a), .o(o[7]));
endmodule
