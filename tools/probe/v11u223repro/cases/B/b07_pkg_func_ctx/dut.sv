// § fixedOuterAssocInnerReg223
package p;
  int qa [int];
  int pa [3][int];
  bit [3:0] pb [2][string];
  function automatic void f();
    int fq [int];
    int fa [4][int];
    fa[0][1] = 2;
    fq[1] = 2;
  endfunction
endpackage
module dut;
  import p::*;
  initial f();
endmodule
