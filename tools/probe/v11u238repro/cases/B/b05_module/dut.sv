// § instBodyMemberWinsFlatLocal238v
// a paren-less module function whose local shares a module variable's name; a select as a part-select base
module top;
  int vals[4];
  logic [15:0] w;
  function automatic int f;
    int vals[$];
    int n;
    foreach (vals[i]) n += vals[i];
    return n;
  endfunction
  function automatic logic [3:0] g;
    logic [3:0] arr[2];
    foreach (arr[i]) g = w[arr[i] +: 4];
  endfunction
  int r;
  initial r = f();
endmodule
