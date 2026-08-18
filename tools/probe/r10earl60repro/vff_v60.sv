// v60 VERIFIER arm F — WHERE EXACTLY the "package did not fold it" boundary is.
// v60e tested only TOP-LEVEL concat/replication.  This arm nests them, and adds
// the CAST family, so the fence can be cut on a measurement instead of a list.
package np;
  localparam logic [3:0] N_cat     = {2'b10, 2'b01};              // top concat
  localparam logic [3:0] N_catop   = {2'b10, 2'b01} + 4'd1;       // concat INSIDE +
  localparam logic [3:0] N_optcat  = 4'd1 + {2'b10, 2'b01};       // concat on the right
  localparam logic [3:0] N_terncat = (1) ? {2'b10,2'b01} : 4'd0;  // concat in a ternary
  localparam logic [3:0] N_replop  = {4{1'b1}} & 4'hF;            // replication INSIDE &
  localparam int         N_catbits = $bits({2'b10, 2'b01});       // concat in a syscall
  localparam logic [1:0] N_catsel  = {2'b10, 2'b01}[1:0];         // part-select of concat
  localparam int         N_cast    = int'(3.7);                   // EXPLICIT cast
  localparam int         N_castr   = int'(4);                     // cast of an int literal
  localparam logic [7:0] N_szcast  = 8'(3);                       // SIZE cast
  localparam int         N_castop  = int'(3) + 1;                 // cast inside +
  localparam int         N_unm     = -4;
  localparam int         N_plain   = 7;
endpackage

module s_np ();
  localparam logic [3:0] u_cat     = np::N_cat;
  localparam logic [3:0] u_catop   = np::N_catop;
  localparam logic [3:0] u_optcat  = np::N_optcat;
  localparam logic [3:0] u_terncat = np::N_terncat;
  localparam logic [3:0] u_replop  = np::N_replop;
  localparam int         u_catbits = np::N_catbits;
  localparam logic [1:0] u_catsel  = np::N_catsel;
  localparam int         u_cast    = np::N_cast;
  localparam int         u_castr   = np::N_castr;
  localparam logic [7:0] u_szcast  = np::N_szcast;
  localparam int         u_castop  = np::N_castop;
  localparam int         u_unm     = np::N_unm;
  localparam int         u_plain   = np::N_plain;
  logic [u_plain-1:0] d;
endmodule

module a1 (); s_np u0 (); endmodule
