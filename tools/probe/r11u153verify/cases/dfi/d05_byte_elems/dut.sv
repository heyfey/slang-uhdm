// § defaultFillImportCopies145 law defaultFillImportIntOnly153v
package pack;
parameter byte V[2] = '{default: 8'd4};
endpackage
module top(output int o);
import pack::V;
assign o = 1;
endmodule
