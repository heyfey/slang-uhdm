// § typedCtorClassArgNet411
class B; int s = 2; endclass
class C extends B; function new(); s = 3; endfunction endclass
module top();
  function automatic B mk();
    B o;
    o = C::new;
    return o;
  endfunction
  B o;
  initial begin
    o = mk();
    $display(o.s);
  end
endmodule
