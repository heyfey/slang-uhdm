// § nestedDefChainName193
module sub (output logic [3:0] o);
  module inner #(parameter int P = 2) (output logic [3:0] q);
    localparam int L = P + 1;
    assign q = 4'(L);
  endmodule
  inner #(.P(5)) u_i (.q(o));
endmodule
module dut (output logic [3:0] o);
  sub u_s (.o(o));
endmodule
