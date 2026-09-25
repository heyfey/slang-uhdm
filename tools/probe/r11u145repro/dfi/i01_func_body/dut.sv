// § defaultFillImportCopies145
package pack;
localparam int unsigned CNT = 2;
localparam int unsigned V[CNT] = '{default: 3};
endpackage
module top(output int o);
import pack::*;
function automatic int f();
  return V[1];
endfunction
assign o = f();
endmodule
