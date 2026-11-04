// § randWithLastSelChainShape296
package p;
  class item;
    rand int lot;
  endclass
  virtual class survey;
    item holds[4];
    int berth;
    extern function int run(input int a);
    pure virtual function int pv();
  endclass
  function int survey::run(input int a);
    int one;
    one = holds[berth].randomize() with { lot < a; };
    return one;
  endfunction
  class s2 extends survey;
    virtual function int pv(); return run(0); endfunction
  endclass
endpackage
module dut;
  initial begin p::s2 x; x = new(); void'(x.pv()); end
endmodule
