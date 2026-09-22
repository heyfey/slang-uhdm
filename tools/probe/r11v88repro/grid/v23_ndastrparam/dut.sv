// v11u88 v23 -- LAW C x the substituted ref_typespec: a net-decl-assign that
// reads an interface localparam of a TYPEDEF'd type, and one of an enum type.
package pk;
  typedef enum logic [3:0] { EA, EB = 2, EC = 3 } e_t;
  typedef logic [7:0] b_t;
endpackage

interface ifc ();
  localparam pk::b_t KB = 8'h2A;
  localparam pk::e_t KE = pk::EC;
  wire [31:0] w_kb = KB;
  wire [31:0] w_ke = KE;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_kb ^ u_if.w_ke;
endmodule
