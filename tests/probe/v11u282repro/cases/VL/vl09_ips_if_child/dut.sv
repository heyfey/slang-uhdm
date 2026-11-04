// § genCaLhsIpsBoundInPlace282
module c #(parameter int P = 2) (output logic [7:0] o);
  if (P > 0) begin : gi
    logic [7:0] v;
    assign v[P +: 4] = 4'hA;
    assign v[7:6] = '0; assign v[1:0] = '0;
    assign o = v;
  end
endmodule
module top(output logic [7:0] o1, o2); c u1(.o(o1)); c #(.P(2)) u2(.o(o2)); endmodule
