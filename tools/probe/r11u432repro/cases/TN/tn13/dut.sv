// § unitOobBodyRefChainName432
class C;
  static int q;
  extern static function int f();
endclass
function int C::f();
  return q;
endfunction
module top;
  initial $display(C::f());
endmodule
