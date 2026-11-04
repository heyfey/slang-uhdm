// § cloneViaProviderTopClone476
package u;
  function automatic string f(string s);
    string r;
    r = s.substr(0, 1);
    r = {r, s};
    return r.toupper();
  endfunction
endpackage
package a;
  import u::*;
  class AC;
    function int g();
      return f("ab").len();
    endfunction
  endclass
endpackage
package t;
  import a::*;
  class TC; AC h; endclass
endpackage
module top; import t::*; TC o; endmodule
