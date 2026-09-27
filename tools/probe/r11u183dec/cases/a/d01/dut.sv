package p;
class e; endclass
class c;
  e elements[$];
  typedef e qe[$];
  virtual function qe get();
    return elements;
  endfunction
endclass
endpackage
module top; endmodule
