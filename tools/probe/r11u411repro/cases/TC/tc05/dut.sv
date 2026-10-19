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
  class F;
    B h;
    function void mk();
      h = D::new;
    endfunction
  endclass
  F f;
  initial begin
    f = new;
    f.mk();
  end
endmodule
