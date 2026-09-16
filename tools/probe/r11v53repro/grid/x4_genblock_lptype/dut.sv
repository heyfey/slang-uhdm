// v11u53 BREAK-4: `localparam type` inside a GENERATE BLOCK.  The alias's
// parent scope is then the generate-block body, and the predicate calls
// Scope::find on it — which calls ensureElaborated().  If forcing elaboration
// of a generate body during the DEFINITION emission perturbs anything, this is
// where it shows.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
endpackage
module dut (output logic o);
  logic [7:0] z;
  generate
    if (1) begin : g
      localparam type GT = pk::req_t;
      localparam int  GW = $bits(GT);
      localparam int  GC = $bits(pk::req_t);   // CONTROL
      assign z = GW[7:0] ^ GC[7:0];
    end
  endgenerate
  assign o = ^z;
endmodule
