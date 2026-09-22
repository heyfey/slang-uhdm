// r11u88 q13 -- LAW A x the COMMONEST corpus shape: a net-decl-assign whose
// RHS is a plain NET reference, a bit select of one, and a port read.  These
// are the forms that decide the Lhs rule (share the listing net vs mint a
// fresh one) on a shape no literal or operation arm can reach.
interface ifc (input logic [31:0] pin);
  wire [31:0] src;
  wire [31:0] w_ref  = src;
  wire        w_bit  = src[3];
  wire [31:0] w_port = pin;
endinterface

module dut (input logic [31:0] pin, output logic [31:0] o);
  ifc u_if (.pin(pin));
  assign o = u_if.w_ref ^ {31'd0, u_if.w_bit} ^ u_if.w_port;
endmodule
