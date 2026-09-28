// § foreachThisArrAtThisToken207 (a static array property, an associative array keyed by string and by class, a super. array control)
package p;
  class B; int barr [$]; endclass
  class C extends B;
    static int sarr [5];
    int aa [string];
    int ac [C];
    function void f();
      foreach (this.sarr[i]) sarr[i] = i;
      foreach (this.aa[key]) aa[key]++;
      foreach (this.ac[h]) ac[h] = 1;
      foreach (super.barr[i]) barr[i] = 0;
    endfunction
  endclass
endpackage
module top; endmodule
