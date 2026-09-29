// § fixedOuterAssocInnerReg223
package p;
  int pa [3][int];
  class c;
    int ca [2][string];
    function void f();
      int fa [4][int];
      fa[0][1] = 2;
    endfunction
  endclass
endpackage
module dut;
  import p::*;
  int ma [2][int];
  initial ma[0][5] = 1;
endmodule
