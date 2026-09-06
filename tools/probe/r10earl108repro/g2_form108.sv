// r10earl108 g2 — THE FORMAL-TYPE AXIS.  The ACTUAL is fixed (a bare,
// wildcard-imported reference to a PACKED-STRUCT package parameter whose own
// initializer is a named assignment pattern); only the FORMAL's declared type
// varies.  Does Surelog substitute the flattened pattern whatever the formal
// is, or only at some widths/kinds?
// MEASUREMENT ONLY.  The official uhdm-cmp is the sole judge.
package q108;
  typedef struct packed {
    logic [1:0] slow_clk_val;
    logic [1:0] core_clk_val;
    logic [1:0] io_clk_val;
    logic       main_pok;
  } rsp_t;

  parameter rsp_t RSP = '{
    slow_clk_val: 2'b01,
    core_clk_val: 2'b01,
    io_clk_val: 2'b10,
    main_pok: 1'b0
  };
endpackage

// a — the corpus formal: a ONE-BIT `bit`
module fa108 #(parameter bit R = 0) (output logic o);
  assign o = R;
endmodule
// b — `int` (32 bits, signed, WIDER than the struct)
module fb108 #(parameter int R = 0) (output logic [31:0] o);
  assign o = R;
endmodule
// c — a packed vector at EXACTLY the struct's width
module fc108 #(parameter logic [6:0] R = 0) (output logic [6:0] o);
  assign o = R;
endmodule
// d — a packed vector NARROWER than the struct
module fd108 #(parameter logic [2:0] R = 0) (output logic [2:0] o);
  assign o = R;
endmodule
// e — an UNTYPED parameter
module fe108 #(parameter R = 0) (output logic [31:0] o);
  assign o = R;
endmodule
// f — the STRUCT formal (the LANDED precedent: this shape must not move)
module ff108 #(parameter q108::rsp_t R = '{default: 0}) (output logic [6:0] o);
  assign o = R;
endmodule
// g — a NO-DEFAULT one-bit formal
module fg108 #(parameter bit R) (output logic o);
  assign o = R;
endmodule
// h — `logic` with NO packed range
module fh108 #(parameter logic R = 0) (output logic o);
  assign o = R;
endmodule
// i — `bit` WITH a packed range at the struct's width
module fi108 #(parameter bit [6:0] R = 0) (output logic [6:0] o);
  assign o = R;
endmodule
// j — `integer`
module fj108 #(parameter integer R = 0) (output logic [31:0] o);
  assign o = R;
endmodule
// k — `logic [0:0]`: a packed range one bit wide
module fk108 #(parameter logic [0:0] R = 0) (output logic o);
  assign o = R;
endmodule
// l — `byte`
module fl108 #(parameter byte R = 0) (output logic [7:0] o);
  assign o = R;
endmodule

module g2_form108
  import q108::*;
(
  output logic        oa,
  output logic [31:0] ob,
  output logic  [6:0] oc,
  output logic  [2:0] od,
  output logic [31:0] oe,
  output logic  [6:0] of,
  output logic        og,
  output logic        oh,
  output logic  [6:0] oi,
  output logic [31:0] oj,
  output logic        ok,
  output logic  [7:0] ol
);
  fa108 #(.R(RSP)) i_a (.o(oa));
  fb108 #(.R(RSP)) i_b (.o(ob));
  fc108 #(.R(RSP)) i_c (.o(oc));
  fd108 #(.R(RSP)) i_d (.o(od));
  fe108 #(.R(RSP)) i_e (.o(oe));
  ff108 #(.R(RSP)) i_f (.o(of));
  fg108 #(.R(RSP)) i_g (.o(og));
  fh108 #(.R(RSP)) i_h (.o(oh));
  fi108 #(.R(RSP)) i_i (.o(oi));
  fj108 #(.R(RSP)) i_j (.o(oj));
  fk108 #(.R(RSP)) i_k (.o(ok));
  fl108 #(.R(RSP)) i_l (.o(ol));
endmodule
