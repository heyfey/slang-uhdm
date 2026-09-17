// r11u65 n3 — PORTS ARE A DIFFERENT KIND (OPS caution (b)).  The same
// unpacked-array typedef used as an ANSI port, a non-ANSI port, and with an
// explicit net keyword, beside the body declaration that is the law's target.
module sub #(parameter int unsigned N = 2, parameter int unsigned D = 4) (
    input  logic [N-1:0] pin  [D],   // port with a DECLARATION unpacked dim
    output logic [N-1:0] pout [D]
);
  assign pout = pin;
endmodule

module dut #(
    parameter int unsigned N = 2,
    parameter int unsigned D = 4
) (
    output logic [N-1:0] o
);
  typedef logic [N-1:0] a_t [D];
  typedef logic [N-1:0] v_t;

  a_t body;                    // THE LAW'S TARGET (body declaration)
  wire v_t wv;                 // explicit NET KEYWORD + packed typedef
  wire [N-1:0] wp [D];         // explicit NET KEYWORD + declaration dim

  logic [N-1:0] pa [D];
  logic [N-1:0] pb [D];
  sub #(.N(N), .D(D)) u (.pin(pa), .pout(pb));

  assign wv = v_t'(0);
  assign o = body[0] | wv | wp[0] | pb[0];
endmodule

module dut2 #(parameter int unsigned N = 2, parameter int unsigned D = 4)
  (o, ai);                     // NON-ANSI header
  output logic [N-1:0] o;
  typedef logic [N-1:0] a_t [D];
  input a_t ai;                // a port DECLARED with the unpacked typedef
  a_t local2;
  assign o = ai[0] | local2[0];
endmodule
