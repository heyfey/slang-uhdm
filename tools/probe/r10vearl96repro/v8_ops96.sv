// r10v96 adversarial arm v8 -- the OTHER Rhs operation shapes at the same
// position: a MULTI assignment pattern `'{2{...}}`, a `'{default:...}` pattern,
// an OVERRIDDEN parameter, and a CONCAT init inside an INTERFACE, inside a
// GENERATE SCOPE and inside a SUBMODULE.  MEASUREMENT ONLY.
package p8o96;
  typedef logic [31:0] y_t;
  localparam y_t YARR [2] = '{ 32'h1, 32'h2 };
endpackage

interface if8o96 import p8o96::*; ();
  localparam y_t ICAT [2] = { 32'h41, 32'h42 };
  localparam y_t IPAT [2] = '{ 32'h43, 32'h44 };
  logic [31:0] v;
  assign v = ICAT[0] ^ IPAT[1];
endinterface

module sub8o96 import p8o96::*; (output logic [31:0] o_o);
  localparam y_t SCAT [2] = { 32'h51, 32'h52 };
  localparam y_t SPAT [2] = '{ 32'h53, 32'h54 };
  assign o_o = SCAT[0] ^ SPAT[1];
endmodule

module m8o96 import p8o96::*; #(parameter y_t OVR [2] = '{ 32'h61, 32'h62 })
                              (output logic [31:0] o_o);
  localparam y_t MULTI [4] = '{ 2{ 32'h71, 32'h72 } };   // MULTI pattern
  localparam y_t DEFP  [3] = '{ default: 32'h73 };       // default pattern
  logic [31:0] sv, gv;
  sub8o96 u_s (.o_o(sv));
  if (1) begin : g8blk
    localparam y_t GCAT [2] = { 32'h81, 32'h82 };
    localparam y_t GPAT [2] = '{ 32'h83, 32'h84 };
    assign gv = GCAT[0] ^ GPAT[1];
  end
  if8o96 u_if ();
  assign o_o = MULTI[0] ^ DEFP[1] ^ OVR[0] ^ sv ^ gv ^ u_if.v ^ YARR[0];
endmodule

module top8o96 (output logic [31:0] a_o);
  m8o96 #(.OVR('{ 32'h91, 32'h92 })) u_m (.o_o(a_o));
endmodule
