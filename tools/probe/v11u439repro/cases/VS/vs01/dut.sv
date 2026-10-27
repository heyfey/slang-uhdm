// § foreachLeadSkipPlaceholder439
module top;
int a[2][3];
function automatic int f();
  int s;
  foreach (a[, j]) s += j;
  return s;
endfunction
initial a[0][0] = f();
endmodule
