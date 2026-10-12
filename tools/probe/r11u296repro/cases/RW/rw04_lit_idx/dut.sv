// § randWithLastSelChainShape296
package p;
  class item;
    rand int lot;
    int w[4];
    function int heft(); return lot; endfunction
  endclass
  class box;
    item holds[4];
    item grid2[2][2];
    item one;
    int idx[4];
  endclass
  class survey;
    item holds[4];
    item grid2[2][2];
    box b;
    int berth;
    function int run(input int a);
      int one;
      int j;
      j = a;
      one = holds[2].randomize() with { lot < 9; };
      return one;
    endfunction
    function int heftj(input int x); return x; endfunction
  endclass
endpackage
module dut;
  initial begin
    p::survey s;
    s = new();
    void'(s.run(0));
  end
endmodule
