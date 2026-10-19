// § typedCtorClassArgNet411
class B; int s = 2; endclass
class C #(int T = 1) extends B; function new(); s = T; endfunction endclass
interface ifc;
  B o;
  initial begin
    o = C#(4)::new;
    $display(o.s);
  end
endinterface
module top();
  ifc u();
endmodule
