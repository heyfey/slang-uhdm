// r11v4 ADVERSARIAL v8 — face (B) with NO tagged_pattern in the def's tree.
// The guard I added keys on `tagged_pattern`; these defaults are written
// POSITIONALLY, so the clone still fires.  Does golden's port view really
// carry the DEFINITION's op75 here?
package p8;
  typedef struct packed { int unsigned A; int unsigned B; } two_t;
  typedef struct packed { two_t T; } nest_t;
  localparam two_t  TDEF = '{32, 64};
  localparam two_t  TOVR = '{11, 22};
  localparam nest_t NDEF = '{'{5, 6}};
  localparam nest_t NOVR = '{'{7, 8}};
endpackage

interface tif #(parameter p8::two_t  T = '{32, 64},   // positional struct
                parameter p8::nest_t N = '{'{5, 6}},  // positional NESTED
                parameter p8::two_t  P = p8::TDEF,    // pkg-localparam ref
                parameter int        U [0:1] = '{3, 4}); // unpacked array
  logic [T.A-1:0] d;
  modport mp (input d);
endinterface

module leaf  (tif q);    logic z; assign z = q.d[0]; endmodule
module leafm (tif.mp q); logic z; assign z = q.d[0]; endmodule

module top;
  tif #(.T(p8::TOVR), .N(p8::NOVR), .P(p8::TOVR), .U('{8, 9})) u_ov();
  tif u_df();
  leaf  a0 (.q(u_ov));
  leaf  a1 (u_ov);
  leafm a2 (.q(u_ov.mp));
  leaf  a3 (.q(u_df));
endmodule
