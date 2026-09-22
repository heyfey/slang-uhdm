// r11v91 BREAK arm v1 — THE REPLACEMENT'S BLAST RADIUS.  LAW A REPLACES the
// landed declaration read for every package-fed hop, so every SIGNED reader
// over a package inner that does not answer signed LOSES its int_typespec.
// The landed law wrote /S on all of these at the base.
package v1p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam logic [15:0]        PU   = 16'd7;   // unsigned logic
  localparam int                 PI   = 16'd5;   // signed int
  localparam shortint            PSH  = 16'd4;   // an abstained atom kind
  localparam byte                PBY  = 8'd6;    // another atom kind
  localparam                     PIMP = 16'd11;  // implicit
  localparam logic [7:0]         PD8  = 16'd5;
endpackage
module v1_pkgsign91;
  localparam logic signed [7:0]  V1 = v1p::PU;   // SIGNED reader, unsigned pkg
  localparam bit   signed [7:0]  V2 = v1p::PU;   // SIGNED bit reader
  localparam integer             V3 = v1p::PU;   // an atom signed reader
  localparam logic signed [7:0]  V4 = v1p::PSH;  // signed reader, atom pkg
  localparam logic signed [15:0] V5 = v1p::PIMP; // signed reader, implicit pkg
  localparam logic signed [7:0]  V6 = v1p::PBY;  // signed reader, byte pkg
  localparam logic signed [7:0]  V7 = v1p::PD8;  // signed reader, unsigned pkg
  localparam v1p::t A = '{bail: 8'hxA, a: V1, b: V2, c: V3, d: V4,
                          e: V5, f: V6, g: V7};
  v1_sink #(.R(A)) s1();
endmodule
module v1_sink #(parameter v1p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
