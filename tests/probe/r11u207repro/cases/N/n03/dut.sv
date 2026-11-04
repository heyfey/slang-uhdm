// § namedUnlinkedWrittenOrder207: an inherited method called with reordered named arguments (golden leaves it unresolved)
package p;
class F;
  function bit mt(int o, int rt, string rtn, string fip = "", bit mot = 1, bit rn = 0);
    return mot;
  endfunction
endclass
class G extends F;
  function void h(int a);
    if (mt(.o(a), .rtn("q"), .rt(3))) $display("m");
    if (mt(.rn(0), .o(a), .rt(3), .rtn("q"))) $display("n");
  endfunction
endclass
endpackage
module top; endmodule
