// § ovUntypedTsDeclWidth427
module sub #(parameter A = 1'b0, parameter B = 4'b0, parameter C = 8, parameter D = 'h7, parameter E = 4'd3, parameter F = 8'hFF, parameter G = 2 + 1)(input a, output o);
  assign o = a ^ A[0] ^ B[0] ^ C[0] ^ D[0] ^ E[0] ^ F[0] ^ G[0];
endmodule
module top(input a, output [7:0] o);
  localparam K = 6'd9;
  sub #(.A(2'd2)) uA(.a(a), .o(o[0]));
  sub #(.B(2'd2)) uB(.a(a), .o(o[1]));
  sub #(.C(2'd2)) uC(.a(a), .o(o[2]));
  sub #(.D(2'd2)) uD(.a(a), .o(o[3]));
  sub #(.E(2'd2)) uE(.a(a), .o(o[4]));
  sub #(.F(2'd2)) uF(.a(a), .o(o[5]));
  sub #(.G(2'd2)) uG(.a(a), .o(o[6]));
  sub u0(.a(a), .o(o[7]));
endmodule
