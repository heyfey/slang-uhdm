// § foreachLeadSkipPlaceholder439
package pk;
int arr2[2][3];
function automatic int f(); int s = 0; foreach (arr2[, j]) s += j; return s; endfunction
endpackage
module top; import pk::*; initial $display(f()); endmodule
