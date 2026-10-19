// § typedCtorNotProgram411v
class B; int s = 2; endclass
class C #(int N = 1) extends B; function new(); s = N; endfunction endclass
module m; endmodule
program top;
  B o, p;
  initial begin
    o = C#(3)::new;
    p = C::new;
  end
endprogram
