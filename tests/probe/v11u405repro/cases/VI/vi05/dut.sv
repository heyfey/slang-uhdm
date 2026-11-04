// § implicitNetOnePerName405
class C;
  int a[4];
  function void f();
    foreach (a[i]) a[i] = i;
    foreach (a[i]) a[i] += 1;
  endfunction
endclass
module top ();
  initial begin C c = new; c.f(); end
endmodule
