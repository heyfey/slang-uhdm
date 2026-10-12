// § randWithLastSelChainShape296
package p;
  class item;
    rand int lot;
  endclass
endpackage
module dut;
  p::item holds[4];
  int k;
  initial begin
    int one;
    holds[0] = new();
    k = 0;
    one = holds[k].randomize() with { lot < 9; };
  end
endmodule
