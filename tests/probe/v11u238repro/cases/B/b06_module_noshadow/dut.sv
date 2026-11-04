// § foreachFlatLocalRefTs238
// a paren-less module function's local with no same-named module variable (b05's control)
module top;
  int other[4];
  function automatic int f;
    int vals[$];
    int n;
    foreach (vals[i]) n += vals[i];
    return n;
  endfunction
  int r;
  initial r = f();
endmodule
