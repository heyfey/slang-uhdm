// v11u74 v6 — LAW B, PACKAGE AND INTERFACE HOMES.  A wildcard-imported
// package variable is a namesake slang's Scope::find may or may not see; an
// interface's generate scope binds the interface body's namesake.
package pk;
  logic [31:0] pkns;
endpackage

interface ifc;
  logic [31:0] i_ns;
  for (genvar i = 0; i < 1; i = i + 1) begin : gi
    logic [31:0] i_ns;
    assign i_ns = 32'd1;
    logic [31:0] pkns;
    assign pkns = 32'd2;
  end
  assign i_ns = 32'd5;
endinterface

module dut (output logic [31:0] o);
  import pk::*;
  logic [31:0] i_ns;
  ifc u_if ();
  for (genvar i = 0; i < 1; i = i + 1) begin : gm
    logic [31:0] pkns;         // namesake only in the imported PACKAGE
    assign pkns = 32'd3;
    logic [31:0] i_ns;         // namesake in the module body
    assign i_ns = 32'd4;
  end
  assign i_ns = 32'd6;
  assign o = u_if.gi[0].i_ns ^ u_if.gi[0].pkns ^ gm[0].pkns ^ gm[0].i_ns
           ^ i_ns ^ pk::pkns;
endmodule
