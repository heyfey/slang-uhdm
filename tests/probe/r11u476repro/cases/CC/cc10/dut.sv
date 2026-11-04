// § cloneViaProviderTopClone476
package u;
  function automatic int f(string s);
    int y;
    y = s.len();
    for (int k = 0; k < s.len(); k++)
      y += k;
    return y;
  endfunction
endpackage
package a;
  import u::*;
  class A;
    function int g();
      return f("ab");
    endfunction
  endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
module top; import t::*; T o; endmodule
