// § foreachThisArrAtThisToken207: controls: super.<array>, a bare array, a handle.<array>, and this.<array> in a class declared inside a module
class B; int ba[3]; endclass
class C extends B;
  int a[3];
  C h;
  function void f();
    foreach (super.ba[i]) ba[i] = 0;
    foreach (a[i]) a[i] = 1;
    foreach (h.a[i]) h.a[i] = 2;
  endfunction
endclass
module top;
  class M;
    int mm[2];
    function void g(); foreach (this.mm[i]) mm[i] = i; endfunction
  endclass
  initial begin M x = new; C c = new; x.g(); c.f(); end
endmodule
