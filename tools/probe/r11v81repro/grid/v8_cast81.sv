// r11v81 adversarial arm v8 — STACKED casts over package hops, and a width
// cast over a NAME (the pass-76/78 ground crossed with LAW A).
package v8p;
  localparam UD = 16'd5;
  localparam UH = 16'h5;
  localparam UU = 5;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e;
  } t8;
  localparam t8 F = '{bail: 8'hxA,
                      a: signed'(unsigned'(UH)),
                      b: 16'(UH),
                      c: int'(UD),
                      d: unsigned'(signed'(UD)),
                      e: signed'(UU)};
endpackage
module v8_cast81 #(parameter v8p::t8 CF = v8p::F) (output logic [23:0] o);
  assign o = CF.a ^ CF.b ^ CF.c ^ CF.d ^ CF.e;
endmodule
