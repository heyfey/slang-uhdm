// § clsAssocVecIdxTs450
class B;
  int a[bit[7:0]];
endclass
class D extends B;
  int b[bit[7:0]];
  function void f();
    a[8'h1] = b[8'h2];
  endfunction
endclass
module top;
  D d = new;
endmodule
