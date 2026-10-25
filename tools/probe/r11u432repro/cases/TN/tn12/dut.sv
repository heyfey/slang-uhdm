// § unitOobBodyRefChainName432
class C;
  int q;
  extern function int f(int a);
endclass
function int C::f(int a);
  return a + q;
endfunction
module top;
  C c;
  initial begin
    c = new;
    $display(c.f(1));
  end
endmodule
