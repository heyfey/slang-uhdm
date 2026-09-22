// r11u86 arm m4 — THE CONTEXT AXIS.  The same three hop spellings (`'d`, `'o`,
// plain unsized decimal) read from a MODULE-homed pattern in every shape the
// emitter has a road for: a module localparam, a module parameter DEFAULT, an
// instance override, a generate-block home, an interface home, a nested
// pattern, an unpacked struct and a packed ARRAY.  Hop home is PACKAGE (the
// size face) and MODULE (the encoding face) side by side.
package m4p;
  localparam PU = 5;
  localparam PD = 16'd5;
  localparam PO = 16'o5;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
  } t4;
  typedef struct packed { logic [23:0] x; logic [23:0] y; } in4;
  typedef struct packed { logic [23:0] bail; in4 n; } nest4;
endpackage
module m4_ctx86 #(parameter m4p::t4 PDEF = '{bail: 8'hxA, a: m4p::PU,
                                             b: m4p::PD, c: m4p::PO})
                 (output logic [23:0] o);
  localparam MU = 5;
  localparam MD = 16'd5;
  localparam MO = 16'o5;
  localparam m4p::t4  LP  = '{bail: 8'hxA, a: m4p::PU, b: m4p::PD, c: m4p::PO};
  localparam m4p::t4  LM  = '{bail: 8'hxA, a: MU,      b: MD,      c: MO};
  localparam m4p::nest4 NP = '{bail: 8'hxA, n: '{x: m4p::PD, y: m4p::PO}};
  localparam m4p::t4  DFLT = '{default: m4p::PD};
  typedef logic [23:0] arr4 [0:2];
  localparam arr4     AR  = '{m4p::PU, m4p::PD, m4p::PO};
  m4_sinkA #(.R('{bail: 8'hxA, a: m4p::PU, b: m4p::PD, c: m4p::PO})) s1(.o());
  m4_sinkB #(.R(LP)) s2(.o());
  if (1) begin : gb
    localparam m4p::t4 GP = '{bail: 8'hxA, a: m4p::PU, b: m4p::PD, c: m4p::PO};
    assign o = GP.a;
  end
endmodule
interface m4_if86;
  localparam m4p::t4 IP = '{bail: 8'hxA, a: m4p::PU, b: m4p::PD, c: m4p::PO};
endinterface
module m4_sinkA #(parameter m4p::t4 R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
module m4_sinkB #(parameter m4p::t4 R = '{default: 0}) (output logic [23:0] o);
  assign o = R.b;
endmodule
