// § instBodyMemberWinsFlatLocal238v
// an interface function: a same-named interface variable (g), none (h)
interface ifc;
  logic [7:0] vals [2];
  function automatic int g;
    int vals[$];
    int n;
    foreach (vals[i]) n += vals[i];
    return n;
  endfunction
  function automatic int h;
    byte bq[$];
    int n;
    foreach (bq[i]) n += bq[i];
    return n;
  endfunction
endinterface
module top;
  ifc u();
  int r;
  initial r = u.g() + u.h();
endmodule
