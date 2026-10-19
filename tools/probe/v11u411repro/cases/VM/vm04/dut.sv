// § callResultMemberDropped411
class C;
  int s = 2;
  static function C mk();
    C o = new;
    return o;
  endfunction
endclass
module top(output int r);
  initial r = C::mk().s;
endmodule
