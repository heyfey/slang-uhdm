// § classCallResultMemberRef413
package pk;
  class C;
    int s = 2;
    static function C mk();
      C o = new;
      return o;
    endfunction
  endclass
endpackage
module top(output int r);
  initial r = pk::C::mk().s;
endmodule
