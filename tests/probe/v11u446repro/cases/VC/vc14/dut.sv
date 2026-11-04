// § cloneBodyCallBindsHomeTopTf446
package p1;
  function int f(int a);
    return a + 1;
  endfunction
  function int g(int a);
    int loc;
    loc = f(a);
    return loc;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
package p3;
  import p2::*;
  import p1::*;
  class c;
    function int m();
      return g(1);
    endfunction
  endclass
endpackage
module top;
  import p3::*;
  c h;
endmodule
