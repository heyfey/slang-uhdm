// § classCallResultMemberRef413
class C;
  int val = 4;
  static C inst;
  static function C get();
    if (inst == null) inst = new;
    return inst;
  endfunction
endclass
module top(output int r);
  initial r = C::get().val + 1;
endmodule
