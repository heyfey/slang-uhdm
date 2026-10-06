// § dupImportSameValueKeeps252
package p;
parameter A = (1<<3);
parameter C = A+1;
endpackage
import p::*;
module top(input logic [A-1:0] i, output logic [C-1:0] o);
  logic [A:0] v [C-1:0];
  assign o = {{(C-A){1'b0}}, i[A-1 -: 4], i[3:0]};
  localparam int Z = A;
endmodule
