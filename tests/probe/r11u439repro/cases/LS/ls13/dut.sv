// § foreachLeadSkipPlaceholder439
module top;
int arr2[2][3];
function automatic int f(); int s = 0; foreach (arr2[, j]) s += j; return s; endfunction
initial $display(f());
endmodule
