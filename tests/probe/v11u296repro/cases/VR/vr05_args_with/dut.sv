// § randWithLastSelChainShape296
package p;
  typedef enum {E0, E1, E2} e_t;
  class item;
    rand int lot;
  endclass
  class survey;
    localparam int LP = 1;
    item holds[4];
    item dq[$];
    item am[string];
    item ai[int];
    int berth;
    e_t ee;
    function int run(input int a);
      int one;
      int j;
      j = a;
      one = holds[j].randomize(lot) with { lot < 9; };
      return one;
    endfunction
  endclass
endpackage
module dut;
  initial begin
    p::survey s;
    s = new();
    void'(s.run(0));
  end
endmodule
