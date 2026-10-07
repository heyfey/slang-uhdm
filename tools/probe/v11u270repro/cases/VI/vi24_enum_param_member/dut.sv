// § insideSetParamFoldKeepsPa270
package up;
  typedef enum logic [1:0] {RD, WR, NOP} op_e;
  parameter op_e OA = RD;
  parameter op_e OB = WR;
endpackage
module top;
  import up::*;
  function automatic bit f(op_e o);
    return o inside {OA, OB};
  endfunction
endmodule
