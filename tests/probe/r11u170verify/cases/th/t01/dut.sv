// § thisPathFormByPosition157
class c;
  int x; int i; int arr[4];
  function int g(int v); return v + 1; endfunction
  function int f();
    arr[this.i] = 1;
    x = g(this.x);
    return this.x;
  endfunction
endclass
module top; c o; initial begin o = new; void'(o.f()); end endmodule
