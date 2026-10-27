// § foreachLeadSkipPlaceholder439
module top;
logic [3:0] q[$][2];
initial foreach (q[, j]) $display(j);
endmodule
