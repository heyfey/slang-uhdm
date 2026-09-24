// § classMethodQualSpan144
class B;
  virtual function void f();
  endfunction
endclass
class C extends B;
  virtual function void f();
    super.f();
  endfunction
endclass
module top; endmodule
