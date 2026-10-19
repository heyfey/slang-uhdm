// § tdAtomRetAliasTwin412
class B;
  typedef int T;
  virtual function T get(); return 0; endfunction
endclass
class D extends B;
  function T get(); return 1; endfunction
endclass
module top;
  D d;
endmodule
