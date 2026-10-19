// § typedCtorClassArgNet411
class B; int s = 2; endclass
class C extends B; function new(int v); s = v; endfunction endclass
module top();
  B o;
  task automatic t();
    o = C::new(5);
  endtask
  initial begin
    t();
    $display(o.s);
  end
endmodule
