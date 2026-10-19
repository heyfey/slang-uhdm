// § typedCtorClassArgNet411
package pk;
  class B; int s = 2; endclass
  class C extends B; function new(); s = 3; endfunction endclass
endpackage
module top();
  pk::B o;
  initial begin
    o = pk::C::new;
    $display(o.s);
  end
endmodule
