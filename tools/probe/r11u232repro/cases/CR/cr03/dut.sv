// § cloneRetNoMintBindsHome232
package p1;
  class c;
    extern function string f(string a);
    extern virtual function int g();
  endclass
  function string c::f(string a);
    f = {a, "x"};
    return f;
  endfunction
  function int c::g();
    g = 3;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
