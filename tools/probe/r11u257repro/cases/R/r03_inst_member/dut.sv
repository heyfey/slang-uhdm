// § ifacePortMemberHighConnParent257 (an interface INSTANCE member as the high-conn, same module)
package p; typedef enum logic [1:0] {A, B} acc_t; typedef struct packed { logic a; logic b; } s_t; endpackage
interface rif; import p::*; logic valid; acc_t access; logic [7:0] address; wire w; s_t st;
  modport register(input valid, input access, input address, input w, input st); endinterface
module dec(input logic [7:0] i_address, input p::acc_t i_access, output logic o_match);
  assign o_match = i_access[0] && |i_address; endmodule
module top; rif r(); logic m; dec u_decoder(.i_address(r.address), .i_access(r.access), .o_match(m)); endmodule
