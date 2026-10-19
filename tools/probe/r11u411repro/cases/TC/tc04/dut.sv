// § typedCtorClassArgNet411
module top();
  class B;
    int s = 2;
  endclass
  class D extends B;
    function new();
      s = 4;
    endfunction
  endclass
  B o, p;
  initial begin
    o = D::new;
    p = D::new();
    $display(o.s, p.s);
  end
endmodule
