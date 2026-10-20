// § classCallResultMemberRef413
class C #(int W = 1);
  int s = W;
  static function C#(W) mk();
    C#(W) o = new;
    return o;
  endfunction
endclass
module top(output int r);
  initial r = C#(2)::mk().s;
endmodule
