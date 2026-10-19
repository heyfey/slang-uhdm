// § typedCtorClassArgNet411
class B; int s = 2; endclass
class C #(type T = int) extends B; function new(T v); s = v; endfunction endclass
module top();
  B o, p;
  initial begin
    o = C#(.T(byte))::new(1);
    p = C#(int)::new(2);
    o = C#(int)::new(3);
  end
endmodule
