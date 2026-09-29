// § hpLvSelIdxNamesByPath224 § hpLvSelColumnJoin224 (a package function's local struct)
package p;
  typedef struct { logic [3:0] arr [4]; } s_t;
  function automatic logic [3:0] f(int i, logic [1:0] d);
    s_t s;
    s.arr[i][1:0] = d;
    return s.arr[i];
  endfunction
endpackage
module top(input int i, input logic [1:0] d, output logic [3:0] o);
  import p::*;
  assign o = f(i, d);
endmodule
