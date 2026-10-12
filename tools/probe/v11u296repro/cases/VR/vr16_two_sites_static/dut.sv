// § randWithLastSelChainShape296
package p;
  class item;
    rand int lot;
  endclass
  class survey;
    static item holds[4];
    int berth;
    function int run(input int a);
      int one;
      one = holds[berth].randomize() with { lot < a; };
      one = one + holds[berth+1].randomize() with { lot < 3; };
      return one;
    endfunction
  endclass
endpackage
module dut;
  initial begin p::survey s; s = new(); void'(s.run(0)); end
endmodule
