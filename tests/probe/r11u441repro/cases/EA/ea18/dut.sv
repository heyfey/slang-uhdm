// § sysCallEmptyArgEndPrevTok441
class C;
  int a;
  function void f();
    $display("x", a,
             , a);
  endfunction
endclass
module top;
  initial begin
    C c = new;
    c.f();
  end
endmodule
