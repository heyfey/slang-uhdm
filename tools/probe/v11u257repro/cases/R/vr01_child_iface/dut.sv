// § ifacePortMemberHighConnParent257 (the child is an interface instance whose input port takes the member)
interface rif; logic valid; logic [7:0] address; modport register(input valid, input address); endinterface
interface sub_if(input logic [7:0] a); logic [7:0] q; assign q = a; endinterface
module common(rif.register register_if, output logic [7:0] o);
  sub_if s(.a(register_if.address)); assign o = s.q; endmodule
module top; rif r(); logic [7:0] o; common u(.register_if(r), .o(o)); endmodule
