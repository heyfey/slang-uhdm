// § cloneViaProviderTopClone476
package u;
  function automatic bit f(string s);
    foreach (s[i])
      if (s[i] == "*")
        return 1;
    return 0;
  endfunction
endpackage
package a;
  import u::*;
  class A;
    function bit g();
      return f("ab");
    endfunction
  endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
module top; import t::*; T o; endmodule
