// § genLpArrRangeFirst263
module sub #(parameter bit [1:0] IV = 0) (output logic [1:0] o);
  assign o = IV;
endmodule
module top(output logic [1:0] o[4]);
  if (1) begin : g_bf
    genvar j;
    for (j = 0; j < 4; ++j) begin : g
      localparam bit [1:0] INITIAL_VALUE[4] = '{2'h0, 2'h1, 2'h2, 2'h3};
      sub #(.IV(INITIAL_VALUE[j])) u (.o(o[j]));
    end
  end
endmodule
