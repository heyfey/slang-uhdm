// § hpVarSelRangeIdxNamesByPath220
class K;
  typedef struct packed { logic [1:0][3:0] pg; logic v; } s_t;
  s_t [1:0] tq;
  function logic [1:0] get(int i);
    return this.tq[0].pg[i-1][1:0];
  endfunction
endclass
module top(output logic [1:0] o);
  K k;
  initial begin k = new; o = k.get(1); end
endmodule
