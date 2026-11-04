// § foreachLeadSkipPlaceholder439
module top;
logic [7:0] m2[2][3];
always_comb foreach (m2[, j]) m2[0][j] = 8'(j);
endmodule
