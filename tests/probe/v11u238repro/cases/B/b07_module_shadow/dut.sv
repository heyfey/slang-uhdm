// § instBodyMemberWinsFlatLocal238v
// b05's shadow alone: a paren-less module function's local beside a same-named module variable
module top;
  int vals[4];
  function automatic int f;
    int vals[$];
    int n;
    foreach (vals[i]) n += vals[i];
    return n;
  endfunction
  int r;
  initial r = f();
endmodule
