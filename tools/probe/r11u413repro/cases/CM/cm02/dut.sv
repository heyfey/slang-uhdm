// § classCallResultMemberRef413
class Abcd;
  int sval = 2;
  static function Abcd make(int v);
    Abcd o = new;
    o.sval = v;
    return o;
  endfunction
endclass
module top(output int r, output int q);
  initial begin
    r = Abcd::make(3).sval;
    q = Abcd::make (r + 1).sval + 1;
  end
endmodule
