// § ifacePortMemberHighConnParent257 (the member inside an expression)
package p; typedef enum logic [1:0] {A, B} acc_t; typedef struct packed { logic a; logic b; } s_t; endpackage
interface rif; import p::*; logic valid; acc_t access; logic [7:0] address; wire w; s_t st;
  modport register(input valid, input access, input address, input w, input st); endinterface
module dec(input logic [7:0] i_address, input p::acc_t i_access, output logic o_match);
  assign o_match = i_access[0] && |i_address; endmodule
module common(rif.register register_if); logic m;
  dec u_decoder(.i_address(register_if.address + 8'd1), .i_access(register_if.access), .o_match(m)); endmodule
module top; rif r(); common u(.register_if(r)); endmodule
