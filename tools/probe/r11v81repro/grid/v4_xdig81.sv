// r11v81 adversarial arm v4 — UNKNOWN-DIGIT stores one hop up: the refusal
// guard's ground.
package v4p;
  localparam PX = 16'hx5;
  localparam PZ = 16'bz;
  localparam PQ = 16'h5;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] x; logic [23:0] z; logic [23:0] q;
  } t4;
  localparam t4 D = '{bail: 8'hxA, x: PX, z: PZ, q: PQ};
endpackage
module v4_xdig81 #(parameter v4p::t4 CD = v4p::D) (output logic [23:0] o);
  assign o = CD.x ^ CD.z ^ CD.q;
endmodule
