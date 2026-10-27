// § foreachLeadSkipPlaceholder439
module top;
logic [7:0] m [int][4];
initial begin m[3] = '{default: 0}; foreach (m[, j]) m[3][j] = 8'(j); end
endmodule
