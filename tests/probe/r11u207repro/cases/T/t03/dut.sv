// § foreachThisArrAtThisToken207: foreach over this.<array> in a class derived from a specialization, an inherited array through this. and a local one (super. keeps a pristine judge face: residue)
package p;
class A #(int N = 2);
  int q[$];
  int f[int];
endclass
class C extends A #(3);
  C h;
  int r[$];
  function void w();
    foreach (this.f[i]) f[i] = i;
    foreach (this.q[j]) q[j] = j;
    foreach (this.r[k]) r[k] = k;
  endfunction
endclass
endpackage
module top; endmodule
