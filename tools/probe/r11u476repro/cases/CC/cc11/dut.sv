// § cloneViaProviderTopClone476
package u;
  function automatic int f(string s);
    int y;
    int pos;
    y = 0;
    for (pos = s.len() - 1; pos > 0; --pos)
      y += pos;
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
