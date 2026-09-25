// § classVarInitSpan152
class C #(type T = int);
  T x;
  static function C#(T) make();
    C#(T) r = new;
    return r;
  endfunction
endclass
module top ();
  C#(byte) c1 = C#(byte)::make();
endmodule
