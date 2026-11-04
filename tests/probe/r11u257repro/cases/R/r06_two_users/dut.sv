// § ifacePortMemberHighConnParent257 (two instances connect the same member: the last writer)
package p; typedef enum logic [1:0] {A, B} acc_t; typedef struct packed { logic a; logic b; } s_t; endpackage
interface rif; import p::*; logic valid; acc_t access; logic [7:0] address; wire w; s_t st;
  modport register(input valid, input access, input address, input w, input st); endinterface
module dec(input logic [7:0] i_address, input p::acc_t i_access, output logic o_match);
  assign o_match = i_access[0] && |i_address; endmodule
module common(rif.register register_if); logic m1, m2;
  dec u_a(.i_address(register_if.address), .i_access(register_if.access), .o_match(m1));
  dec u_b(.i_address(register_if.address), .i_access(register_if.access), .o_match(m2)); endmodule
module top; rif r(); common u(.register_if(r)); endmodule
