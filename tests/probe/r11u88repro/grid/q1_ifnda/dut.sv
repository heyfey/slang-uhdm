// r11u88 q1 -- LAW A, the clean net-decl-assign face of an interface (a3
// without the strength-decorated declaration, which is its own decline).
package pk;
  typedef enum logic [1:0] { EA, EB = 2 } e_t;
endpackage

interface ifc ();
  wire [31:0] w_nd = 32'd11;
  wire [31:0] w_nde = pk::EB;
  logic [31:0] c_plain;
  assign c_plain = 32'd13;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_nd ^ u_if.w_nde ^ u_if.c_plain;
endmodule
