// § foreachThisArrAtThisToken207: foreach over this.<object>.<array>, this.<struct>.<array> and this.<array> of a property object
package p;
typedef struct { int a[4]; } s_t;
class I; int arr[5]; int q[$]; endclass
class C;
  I obj;
  s_t s;
  int aa[string];
  function void f();
    foreach (this.obj.arr[i]) obj.arr[i] = i;
    foreach (this.s.a[k]) s.a[k] = k;
    foreach (this.aa[key]) aa[key]++;
    foreach (this.obj.q[j]) obj.q[j]--;
  endfunction
endclass
endpackage
module top; endmodule
