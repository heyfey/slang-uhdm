// v11u88 v12 -- a net-decl-assign whose RHS is a NAME that is NOT a parameter:
// another net, a port, and a bit select.
interface ifc (input logic [31:0] pi);
  wire [31:0] w_src = 32'd11;
  wire [31:0] w_ref = w_src;
  wire [31:0] w_port = pi;
  wire w_bit = w_src[3];
endinterface

module dut (input logic [31:0] i, output logic [31:0] o);
  ifc u_if (.pi(i));
  assign o = u_if.w_ref ^ u_if.w_port ^ {31'd0, u_if.w_bit};
endmodule
