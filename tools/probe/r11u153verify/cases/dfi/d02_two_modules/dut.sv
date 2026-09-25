// § defaultFillImportCopies145
package pack;
parameter int unsigned V[2] = '{default: 3};
endpackage
module sub(output int o);
import pack::*;
assign o = 0;
endmodule
module top(output int o, output int p);
import pack::*;
sub u(.o(p));
assign o = 1;
endmodule
