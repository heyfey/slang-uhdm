// § classArrElemVar414
module top();
  virtual class B; pure virtual function void f(); endclass
  class D extends B; virtual function void f(); endfunction endclass
  B arr[2];
  D d;
  initial begin d = new; arr[0] = d; arr[0].f(); end
endmodule
