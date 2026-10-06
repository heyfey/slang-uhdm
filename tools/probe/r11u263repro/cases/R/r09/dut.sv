// § genLpArrRangeFirst263
module sub #(parameter bit [1:0] P = 0) (output logic [1:0] o);
  assign o = P;
endmodule
module top(output logic [1:0] o[2][2]);
  for (genvar i = 0; i < 2; i++) begin : a
    for (genvar j = 0; j < 2; j++) begin : b
      localparam bit [1:0] IV[4] = '{2'h0, 2'h1, 2'h2, 2'h3};
      sub #(.P(IV[i+j])) u (.o(o[i][j]));
    end
  end
endmodule
