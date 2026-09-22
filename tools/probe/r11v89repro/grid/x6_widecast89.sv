// r11v89 break arm x6 — LAW B THROUGH A SIGN CAST.  `red86HopName86` reads
// THROUGH `signed'`/`$signed`/`$unsigned`, so a cast over a MODULE-homed hop
// wider than 64 bits now passes the relaxed fence.  The landed encoding law
// records that a cast MINTS a fresh constant with its own typespec
// (`z6_sign86`), so golden's answer there need not be the hop's.
package x6p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module x6_widecast89;
  localparam logic [95:0]        YW  = 96'd12;
  localparam logic [95:0]        YO  = 96'o17;
  localparam logic signed [95:0] YS  = 96'd12;
  localparam x6p::t A = '{bail: 8'hxA, a: signed'(YW), b: $signed(YW),
                          c: $unsigned(YW), d: signed'(YO),
                          e: $unsigned(YO), f: signed'(YS), g: YW};
  x6_sink #(.R(A)) s1();
endmodule
module x6_sink #(parameter x6p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
