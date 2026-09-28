// § foreachThisArrAtThisToken207: this.<array> written by a macro, and in a parameterized class specialization used from a module, both views
`define FE(a) foreach (this.a[i]) a[i] = i;
package p;
class C #(int N = 2);
  int arr[N];
  int lng_name[N];
  function void f();
    `FE(arr)
    foreach (this.lng_name[i]) lng_name[i] = N;
  endfunction
endclass
endpackage
module top;
  initial begin p::C #(3) c = new; c.f(); end
endmodule
