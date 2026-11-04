// § typedCtorClassArgNet411
class B; int s = 2; endclass
class C extends B; function new(); s = 3; endfunction endclass
module top();
  B o, p;
  for (genvar i = 0; i < 1; i++) begin : g
    initial begin
      o = C::new;
      p = C::new;
      $display(o.s);
    end
  end
endmodule
