// r11u85 a3 -- LAW A: the NET-DECL-ASSIGN face.  `VpiNetDeclAssign` is the
// FIRST field `cont_assign::Compare` reads; a net declaration assignment in an
// interface body sets it, and the elab clone must carry it.
package pk;
  typedef enum logic [1:0] { EA, EB = 2 } e_t;
endpackage

interface ifc ();
  wire [31:0] w_nd = 32'd11;
  wire (strong1, weak0) [31:0] w_nds = 32'd12;
  wire [31:0] w_nde = pk::EB;
  logic [31:0] c_plain;
  assign c_plain = 32'd13;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_nd ^ u_if.w_nds ^ u_if.w_nde ^ u_if.c_plain;
endmodule
