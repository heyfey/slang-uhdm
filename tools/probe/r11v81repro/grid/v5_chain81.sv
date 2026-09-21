// r11v81 adversarial arm v5 — CROSS-PACKAGE hops, qualified and imported,
// and a chain whose LAST hop is a DecConst over a Hex store.
package v5a;
  localparam A = 16'h5;
  localparam D = 16'd7;
endpackage
package v5b;
  import v5a::*;
  localparam B  = A;
  localparam Bq = v5a::A;
  localparam Dq = v5a::D;
  localparam Dd = Dq;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] b; logic [23:0] bq; logic [23:0] dq;
    logic [23:0] dd;
  } t5;
  localparam t5 E = '{bail: 8'hxA, b: B, bq: Bq, dq: Dq, dd: Dd};
endpackage
module v5_chain81 #(parameter v5b::t5 CE = v5b::E) (output logic [23:0] o);
  assign o = CE.b ^ CE.bq ^ CE.dq ^ CE.dd;
endmodule
