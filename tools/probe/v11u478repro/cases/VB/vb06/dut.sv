// § providerBodyCopyBind478 (a foreach over a local array)
package u;
  class C; endclass
  function automatic void f();
    int arr[3];
    int s;
    foreach (arr[i]) s += arr[i];
  endfunction
endpackage
package a;
  import u::*;
  class A;
    function void g();
      f();
    endfunction
  endclass
endpackage
package t0;
  import a::*;
  class T0; A h; endclass
endpackage
module top; import t0::*; T0 o; endmodule
