// § tfLocalClassArrElemClassTs452
package p;
  class C;
    int x;
  endclass
  function void f();
    C arr[2];
    arr[0] = new;
  endfunction
endpackage
module top;
  import p::*;
endmodule
