// § foldIntTsSignedKwTrim286
module sub #(parameter int signed P = 2) (output logic [7:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = P + i;
  end
endmodule
module top;
  logic [7:0] o1 [2], o2 [2];
  sub #(.P(-1)) u1(.o(o1));
  sub u2(.o(o2));
endmodule
