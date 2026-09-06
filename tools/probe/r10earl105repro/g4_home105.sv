// r10earl105 g4 — the HOMES a bare read can resolve to, from inside an
// ELABORATED loop-generate cont_assign.  Every parameter carries a NON-decimal
// encoding so a COPY and a MINT are distinguishable.
package pk105;
  parameter logic [7:0] PKB = 8'b0000_1001;
endpackage

interface if105 #(parameter logic [7:0] IFP = 8'b0000_0110) (input logic clk);
  logic [63:0] iw;
  for (genvar g = 0; g < 2; g++) begin : gen_if
    logic [63:0] q;
    assign q = IFP ^ {8{clk}};        // an INTERFACE's own parameter
  end
endinterface

module g4_leaf105 #(parameter logic [7:0] PORTP = 8'b0000_0111) (
  input  logic [7:0] sig,
  output logic [63:0] z
);
  import pk105::*;
  localparam logic [7:0] MODP  = 8'b0000_0101;
  localparam logic [7:0] OUTER = 8'b0000_1010;

  for (genvar i = 0; i < 2; i++) begin : gen_l
    localparam logic [7:0] GENP = 8'b0000_1000;   // a GEN-LOCAL localparam
    logic [63:0] n1, n2, n3, n4, n5, n6;
    assign n1 = MODP  ^ sig;                 // the module's own localparam
    assign n2 = PORTP ^ sig;                 // a PORT parameter
    assign n3 = GENP  ^ sig;                 // the gen scope's OWN localparam
    assign n4 = pk105::PKB ^ sig;            // a PACKAGE parameter, qualified
    assign n5 = PKB   ^ sig;                 // a PACKAGE parameter, imported
    if (i == 0) begin : gen_n                // a NESTED gen-if inside the loop
      assign n6 = OUTER ^ sig;
    end else begin : gen_m
      assign n6 = MODP ^ sig;
    end
  end
  assign z = 64'b0;
endmodule

module g4_home105 (input logic clk, input logic [7:0] sig, output logic [63:0] z);
  logic [63:0] zc;
  g4_leaf105 #(.PORTP(8'b0000_1011)) u_leaf (.sig(sig), .z(zc));   // a CHILD instance
  if105 u_if (.clk(clk));
  // a gen-IF scope (not a loop) in the TOP module, for the non-loop control
  localparam logic [7:0] TOPP = 8'b0000_1100;
  if (1) begin : gen_top_if
    logic [63:0] t1;
    assign t1 = TOPP ^ sig;
  end
  assign z = zc;
endmodule
