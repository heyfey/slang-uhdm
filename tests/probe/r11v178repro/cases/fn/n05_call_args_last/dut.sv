// § refFullNameThroughNamedExpr175
class B; function int h(int x); return x; endfunction endclass
class K extends B;
  K o;
  int arr[4];
  function int f(int k);
    int s;
    s = this.h(k) + super.h(k+1) + o.h(k) + o.arr[k] + this.arr[k];
    return s;
  endfunction
endclass
module top; endmodule
