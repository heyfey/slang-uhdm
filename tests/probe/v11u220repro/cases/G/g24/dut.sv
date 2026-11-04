// § hpVarSelRangeIdxNamesByPath220
typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
class base;
  s_t m;
endclass
class der extends base;
  function logic [1:0] f(int i);
    return super.m.arr[i][1:0] ^ this.m.arr[i+1][3:2];
  endfunction
endclass
module top; endmodule
