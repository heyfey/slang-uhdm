// § ifacePortMemberHighConnParent257 (the interface passed down through two ports)
package p; typedef enum logic [1:0] {A, B} acc_t; endpackage
interface rif; import p::*; logic valid; acc_t access; logic [7:0] address;
  modport register(input valid, input access, input address); endinterface
module dec(input logic [7:0] i_address, input p::acc_t i_access, output logic o_match);
  assign o_match = i_access[0] && |i_address; endmodule
module common(rif.register register_if); logic m;
  dec u_decoder(.i_address(register_if.address), .i_access(register_if.access), .o_match(m)); endmodule
module mid(rif.register register_if); common u_common(.register_if(register_if)); endmodule
module top; rif r(); mid u(.register_if(r)); endmodule
