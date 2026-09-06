// r10earl111 arm g3 -- THE SCOPE MATRIX.  The same declared type (`int
// unsigned`) and the same select shape everywhere; only the parameter's HOME
// moves.  The package rows are the PREDECESSOR FLOOR (§ elabHierSelWidthFold /
// § stampFoldedPkgParamTs already stamp them and must keep doing so to the
// byte); the module rows are what this law adds.
package pk3111;
  localparam int unsigned PKE = 2;   // package, EXPLICIT  -- predecessor floor
  localparam              PKI = 2;   // package, IMPLICIT  -- predecessor floor
  typedef struct packed { logic [31:0] src; logic v; } h_t;
endpackage

interface if3111;
  localparam int unsigned IFE = 2;   // INTERFACE localparam
  pk3111::h_t d;
  modport mp (input d);
endinterface

module s3111 #(parameter int M = 4,
               localparam int unsigned PLE = 2)   // PARAMETER PORT LIST
              (input pk3111::h_t h_i, output logic [63:0] o);
  localparam int unsigned BDY = 2;                // module BODY
  logic [63:0] r;
  for (genvar gi = 0; gi < 1; gi++) begin : g1
    localparam int unsigned GEN = 2;              // GENERATE-BLOCK localparam
    assign r[ 1: 0] = h_i.src[0 +: BDY];
    assign r[ 3: 2] = h_i.src[0 +: PLE];
    assign r[ 5: 4] = h_i.src[0 +: GEN];
    assign r[ 7: 6] = h_i.src[0 +: pk3111::PKE];
    assign r[ 9: 8] = h_i.src[0 +: pk3111::PKI];
    for (genvar gj = 0; gj < 1; gj++) begin : g2
      localparam int unsigned GEN2 = 2;           // depth TWO
      assign r[11:10] = h_i.src[0 +: GEN2];
      assign r[13:12] = h_i.src[0 +: BDY];
    end
  end
  // depth ZERO -- the module body itself
  assign r[15:14] = h_i.src[0 +: BDY];
  assign o = r;
endmodule

module g3_scope111;
  pk3111::h_t s;
  logic [63:0] oo;
  s3111 #(.M(4)) u (.h_i(s), .o(oo));
endmodule
