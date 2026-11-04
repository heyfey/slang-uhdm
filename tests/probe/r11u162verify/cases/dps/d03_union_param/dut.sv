// § defPkgStructParamMemberNames154
package p; typedef union packed { logic [7:0] w; logic [7:0] v; } u_t; endpackage
interface tif #(parameter p::u_t U = 8'h5); logic [7:0] s; endinterface
module top(output logic [7:0] o); tif t(); assign o = t.s; endmodule
