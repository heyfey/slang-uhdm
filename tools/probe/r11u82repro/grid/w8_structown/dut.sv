// v11u82 w8 -- LAW B BREAK, the converse of w7.  Surelog classifies a
// PACKED-STRUCT-typed declaration as a struct_NET, which its search reaches in
// the NETS vector; slang calls the same declaration a Variable.  So a package
// PLAIN VARIABLE colliding with a module-own STRUCT should bind the MODULE's
// object (the struct is a net on the producer's side and nets go first), while
// `impNet || !ownNet` reads both as variables and takes the package's.
package pc;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } zs_t;
  logic [7:0] z_pv;   // package PLAIN VAR  vs module STRUCT   -> module's?
  zs_t        z_ps;   // package STRUCT     vs module PLAIN VAR-> package's?
  logic [7:0] z_ctl;  // package PLAIN VAR  vs module PLAIN VAR-> package's (control)
endpackage

module dut (output logic [31:0] o);
  import pc::*;
  pc::zs_t     z_pv;   // module's own is a PACKED STRUCT
  logic [15:0] z_ps;   // module's own is a plain variable
  logic [15:0] z_ctl;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] z_pv;  assign z_pv  = 32'd1;
    logic [31:0] z_ps;  assign z_ps  = 32'd2;
    logic [31:0] z_ctl; assign z_ctl = 32'd3;
  end
  assign o = gv[0].z_pv ^ gv[0].z_ps ^ gv[0].z_ctl;
endmodule
