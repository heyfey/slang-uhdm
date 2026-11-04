// § foreachThisArrAtThisToken207: this.<array> where the enclosing method has a formal of the same name, and where a local of the same name shadows it
package p;
class C;
  int regs[$];
  int m[4];
  function void get(ref int regs[$]);
    foreach (this.regs[rg]) regs.push_back(this.regs[rg]);
  endfunction
  function void g();
    int m[2];
    foreach (this.m[i]) m[i % 2] = this.m[i];
  endfunction
endclass
endpackage
module top; endmodule
