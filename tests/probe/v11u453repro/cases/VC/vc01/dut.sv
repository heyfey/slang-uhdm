// § vsTrailRangeColonJoin453
class C;
  static function void f(int i0);
    logic [3:0][7:0] m;
    m[i0][i0+:2] = 1;
  endfunction
endclass
module top;
  initial C::f(1);
endmodule
