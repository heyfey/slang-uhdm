`define CALLM(x) mt(.o(x), .rt(3), .rtn("q"))
class F;
  function bit mt(int o, int rt, string rtn, string fip = "", bit mot = 1, bit rn = 0);
    return mot;
  endfunction
  function void g(int a);
    if (mt(.o(a), .rt(2), .rtn("x"), .fip("y"), .rn(1))) $display("a");
    if (`CALLM(a)) $display("m");
  endfunction
endclass
