// § randWithLastSelChainShape296
package p;
  class item;
    rand int lot;
  endclass
  class base;
    item holds[4];
  endclass
  class survey extends base;
    int berth;
    function int run(input int a);
      int one;
      one = super.holds[berth].randomize() with { lot < a; };
      one += holds[a].randomize() with { lot > a; };
      return one;
    endfunction
  endclass
endpackage
module dut;
  initial begin p::survey s; s = new(); void'(s.run(0)); end
endmodule
