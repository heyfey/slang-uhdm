// § classCallResultMemberRef413
package pk;
  class C;
    int s = 5;
    static function C mk(int a);
      C o = new;
      o.s = a;
      return o;
    endfunction
  endclass
endpackage
module top(output int r);
  int z = 2;
  initial r = pk::C::mk(z).s;
endmodule
