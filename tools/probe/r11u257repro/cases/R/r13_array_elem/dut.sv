// § ifacePortMemberHighConnParent257 (an element of an interface array as the actual)
package p; typedef enum logic [1:0] {A, B} acc_t; endpackage
interface rif; import p::*; logic valid; acc_t access; logic [7:0] address;
  modport register(input valid, input access, input address); endinterface
module dec(input logic [7:0] i_address, input p::acc_t i_access, output logic o_match);
  assign o_match = i_access[0] && |i_address; endmodule
module common(rif.register register_if); logic m;
  dec u_decoder(.i_address(register_if.address), .i_access(register_if.access), .o_match(m)); endmodule
module top; rif r[2](); common u0(.register_if(r[0])); common u1(.register_if(r[1])); endmodule
