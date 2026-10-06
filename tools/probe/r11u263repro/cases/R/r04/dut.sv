// § genLpArrRangeFirst263
typedef logic [3:0] nib_t;
module sub #(parameter nib_t P = 0) (output logic [3:0] o);
  assign o = P;
endmodule
module top(output logic [3:0] o[2]);
  for (genvar i = 0; i < 2; i++) begin : g
    if (1) begin : h
      localparam nib_t N[2] = '{4'h1, 4'h2};
      sub #(.P(N[i])) u (.o(o[i]));
    end
  end
endmodule
