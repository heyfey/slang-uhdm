// § typedCtorClassArgNet411
module top();
  class B;
    int s = 2;
    function new(int def = 3);
      s = def;
    endfunction
  endclass
  class C #(int t = 1) extends B;
    int a;
    function new(int def = 42);
      super.new(def + t);
      a = def;
    endfunction
  endclass
  B o;
  initial begin
    o = C#(.t(2))::new(.def(4));
    $display(o.s);
  end
endmodule
