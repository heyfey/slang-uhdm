// § defPkgStructParamMemberNames154
package pa; typedef struct packed { logic [3:0] X; } in_t; endpackage
package pb; typedef struct packed { pa::in_t I; logic [3:0] Y; } cfg_t; endpackage
module mm #(parameter pb::cfg_t C = '{I: '{X: 1}, Y: 2}) (output logic [7:0] o); assign o = C.Y; endmodule
module top(output logic [7:0] o); mm u(o); endmodule
