// § tfLocalClassArrElemClassTs452
package p;
  class C;
    int x;
  endclass
endpackage
module top;
  import p::*;
  function automatic void f();
    C arr[3];
    foreach (arr[i]) arr[i] = new;
  endfunction
endmodule
