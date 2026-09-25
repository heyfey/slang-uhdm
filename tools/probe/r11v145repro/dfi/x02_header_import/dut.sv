// § defaultFillImportCopies145
package pack;
parameter int V[2] = '{default: 7};
endpackage
module top import pack::*; (output int o);
assign o = V[0] + V[1];
endmodule
