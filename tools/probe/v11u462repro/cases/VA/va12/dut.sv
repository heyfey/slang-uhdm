// § clsMethodOwnAutomatic462
class C;
  task automatic t(input int a, output int b);
    int k;
    k = a;
    b = k;
  endtask
  function automatic void f(ref int x); x = 1; endfunction
endclass
module top;
  initial begin C c; int y; c = new; c.t(1, y); c.f(y); end
endmodule
