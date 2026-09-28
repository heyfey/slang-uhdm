// § namedUnlinkedWrittenOrder207: an extern method called with named arguments before its body, a middle formal skipped (BuildUVMPkg's m_matches_type_override)
package p;
class F;
  extern function bit mt(int o, int rt, string rtn, string fip = "", bit mot = 1, bit rn = 0);
  extern function void g(int a);
endclass
function void F::g(int a);
  if (mt(.o(a), .rt(2), .rtn("x"), .fip("y"), .rn(1))) $display("a");
  if (mt(.o(a), .rt(2), .rtn("x"), .fip("y"), .mot(0), .rn(1))) $display("b");
  if (mt(.o(a), .rt(2), .rtn("x"))) $display("c");
  if (mt(.o(a), .rt(2), .rtn("x"), .rn(a > 1))) $display("d");
endfunction
function bit F::mt(int o, int rt, string rtn, string fip = "", bit mot = 1, bit rn = 0);
  return mot;
endfunction
endpackage
module top; endmodule
