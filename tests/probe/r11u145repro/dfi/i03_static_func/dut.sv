// § defaultFillImportCopies145
package pack;
localparam int unsigned CNT = 2;
localparam int unsigned V[CNT] = '{default: 3};
endpackage
module top(output int o);
import pack::*;
typedef int unsigned T[CNT];
function static T F();
  for (int i = 0; i < CNT; i++) F[i] = V[i];
endfunction
localparam int unsigned W[CNT] = F();
assign o = W[0];
endmodule
