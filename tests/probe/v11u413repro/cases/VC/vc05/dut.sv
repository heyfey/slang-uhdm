// § classCallResultMemberRef413
class C;
  int s = 2;
  static function C mk();
    C o = new;
    return o;
  endfunction
endclass
class D;
  int y;
  function void f();
    y = C::mk().s;
  endfunction
endclass
module top;
  D d;
  initial begin d = new; d.f(); end
endmodule
