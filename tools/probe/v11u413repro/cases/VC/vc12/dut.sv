// § classCallResultMemberRef413
class C #(int W = 2);
  int s = W;
  static function C#(W) mk();
    C#(W) o = new;
    return o;
  endfunction
endclass
typedef C#(4) C4;
module top(output int r);
  initial r = C4::mk().s;
endmodule
