// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue this. member path with two selects
class Grid;
  typedef struct { logic [7:0] m2 [2][2]; } p_t;
  p_t pkt;
  function logic [7:0] f(int k);
    logic [7:0] r;
    r = this.pkt.m2[k][1];
    return r;
  endfunction
endclass
module top; Grid g; initial g = new; endmodule
