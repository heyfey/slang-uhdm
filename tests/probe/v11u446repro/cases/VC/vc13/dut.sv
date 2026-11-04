// § clsBodyCallBindsHomeTopTf446
package p1;
  function int f(int a);
    int loc;
    loc = a;
    return loc + 1;
  endfunction
endpackage
package p2;
  import p1::*;
  int p2v = 1;
endpackage
package p3;
  import p1::*;
  import p2::*;
  class c;
    int r;
    function void m();
      r = f(1);
    endfunction
  endclass
endpackage
module top;
  import p3::*;
  c h;
endmodule
