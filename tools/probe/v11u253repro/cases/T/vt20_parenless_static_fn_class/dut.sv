// § cloneTfItemLocalOwnVar253 (a static paren-less out-of-block method with a string local and a queue local)
package p;
  class c;
    extern static function string f;
  endclass
  function string c::f;
    string s;
    int qq[$];
    s = "a";
    qq.push_back(1);
    s = {s, "b"};
    return s;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
