// c10 — the VIEW matrix on a MODULE holder: the `#(parameter …)` header form
// (struct_param_func_arg's shape), a second instance, a wildcard-importing
// module, and a re-pass of the whole struct into a child.
package p;
  typedef struct packed {
    int unsigned a;
    logic [63:0] b;
    bit          c;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.a = 3;
    r.b = 64'h1000;
    r.c = 1'b1;
    return r;
  endfunction
  function automatic logic in_region(cfg_t C, logic [63:0] x);
    if (C.a != 0) return (x >= C.b);
    else          return 1'b1;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    input  logic [63:0] a_i,
    output logic        o_fn,
    output logic [31:0] o_direct
);
  assign o_fn     = p::in_region(CFG, a_i);
  assign o_direct = CFG.a;
endmodule

module imp;
  import p::*;
  localparam cfg_t IC = build();
  child #(.W(IC.a)) u4();
endmodule

module top(input logic [63:0] a_i, output logic o1, output logic o2,
           output logic [31:0] d1, output logic [31:0] d2);
  dut u1(.a_i(a_i), .o_fn(o1), .o_direct(d1));
  dut u2(.a_i(a_i), .o_fn(o2), .o_direct(d2));
  imp u3();
endmodule

module child #(parameter int unsigned W = 1) (); endmodule
