// § scopedCallPrefixEndsAtColons270
package p;
  class cfg #(type T = int);
    static function bit get(string n, ref T v);
      return 1;
    endfunction
  endclass
  class user;
    int v;
    function void mk();
      void'(cfg#(int)::
            get("a", v));
      if (!cfg#(int)::  get("b", v)) v = 0;
    endfunction
  endclass
endpackage
module top;
endmodule
