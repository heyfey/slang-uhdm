// § instBodyMemberWinsFlatLocal238v
// a paren-less module function's local beside a same-named module parameter and a generate-scope variable
module top #(parameter int vals = 2);
  if (1) begin : g
    int qv[3];
  end
  function automatic int f;
    int vals[$];
    int qv[$];
    int n;
    foreach (vals[i]) n += vals[i];
    foreach (qv[i]) n += qv[i];
    return n;
  endfunction
  int r;
  initial r = f();
endmodule
