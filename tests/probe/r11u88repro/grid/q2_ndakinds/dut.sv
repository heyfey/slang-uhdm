// r11u88 q2 -- LAW A x the RHS kinds a net-decl-assign can carry in an
// interface: a sized literal, an UNSIZED decimal, a localparam name, an
// operation over two nets, a concatenation and a package parameter.
package pk;
  localparam int PK = 7;
endpackage

interface ifc ();
  localparam int K = 5;
  wire [31:0] a;
  wire [31:0] b;
  wire [31:0] w_lit  = 32'd11;
  wire [31:0] w_uns  = 12;
  wire [31:0] w_par  = K;
  wire [31:0] w_op   = a ^ b;
  wire [3:0]  w_cat  = {2'b01, 2'b10};
  wire [31:0] w_pkg  = pk::PK;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_lit ^ u_if.w_uns ^ u_if.w_par ^ u_if.w_op ^
             {28'd0, u_if.w_cat} ^ u_if.w_pkg;
endmodule
