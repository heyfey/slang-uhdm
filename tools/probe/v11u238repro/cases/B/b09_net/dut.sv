// § instBodyMemberWinsFlatLocal238v
// a paren-less module function's local beside a same-named module NET
module top;
  wire [3:0] vals;
  function automatic int f;
    int vals[$];
    int n;
    foreach (vals[i]) n += vals[i];
    return n;
  endfunction
  int r;
  initial r = f();
endmodule
