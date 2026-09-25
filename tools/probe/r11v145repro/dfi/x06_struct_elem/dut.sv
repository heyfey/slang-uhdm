// § defaultFillImportCopies145
package pack;
typedef struct packed { logic [3:0] a; logic b; } s_t;
localparam s_t V[2] = '{default: '0};
endpackage
module top(output logic o);
import pack::*;
assign o = V[1].b;
endmodule
