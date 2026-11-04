// § defPkgStructParamMemberNames154
package p; typedef struct packed { logic [3:0] A; logic [3:0] B; } cfg_t; endpackage
interface tif #(parameter p::cfg_t C = '{A: 1, B: 2}); logic [7:0] s; endinterface
module mm(tif t, output logic [7:0] o); assign o = t.s; endmodule
module top(output logic [7:0] o); tif t(); mm u(t, o); endmodule
