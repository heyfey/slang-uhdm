// § enumCastChainKeepsInnerCast493
class G #(type T = int);
  static function int f();
    return int'(int'(T::get()));
  endfunction
endclass
module top;
endmodule
