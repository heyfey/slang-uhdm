// § insideSetParamFoldKeepsPa270
package up;
  typedef enum logic [1:0] {RD, WR, NOP} op_e;
  typedef logic [3:0] nib_t;
  parameter op_e OA = RD;
  parameter op_e OB = WR;
  parameter nib_t NA = 4'h3;
  parameter logic [3:0] VA = 4'h5;
  parameter bit [7:0] BA = 8'd9;
endpackage
module top;
  import up::*;
  function automatic bit f(op_e o, logic [3:0] n);
    return (n inside {NA, VA}) && (n inside {BA});
  endfunction
endmodule
