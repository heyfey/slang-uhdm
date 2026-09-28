// § foreachThisArrAtThisToken207: foreach over this.<array> inside a nested class of a package, in a static method's handle, with a dynamic array and with a multi-dimensional associative array, next to a local array of the same name
package p;
class C;
  int ta [];
  int md [string][int];
  int loc [$];
  function void f();
    int loc [5];
    foreach (this.ta[i]) ta[i] = i;
    foreach (this.md[s, i]) md[s][i] = i;
    foreach (this.loc[j]) this.loc[j] = loc[j];
    foreach (loc[j]) loc[j] = j;
  endfunction
endclass
endpackage
module top; endmodule
