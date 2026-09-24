// § elabCloneInstTreeUnstored144
module gen_test(input [3:0] in, output out);
genvar s, j;
generate
  for (s = 0; s < 2; s = s + 1) begin : st
    for (j = 0; j < 2; j = j + 1) begin : inner
      wire temp;
      assign temp = in[j];
    end
    wire val;
    assign val = st[s].inner[1].temp;
  end
endgenerate
assign out = st[0].val;
endmodule
