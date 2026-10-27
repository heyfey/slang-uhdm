// § foreachLeadSkipPlaceholder439
module top;
logic [3:0] a[2][3];
always_comb begin
  foreach (a[, j]) a[0][j] = 4'(j);
end
endmodule
