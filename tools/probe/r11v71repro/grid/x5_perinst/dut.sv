// v11u71 x5 — PER-INSTANCE ANSWERS.  The same module text is instantiated
// twice with DIFFERENT namesake widths, so one emitted law must give two
// different sizes; and a namesake in the ANCESTOR instance's body is reachable
// while one in the ancestor's GEN block is not (gen scopes are recursed past).
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage

module leaf #(parameter p::cfg_t C = p::LIT, parameter W = 8)
  (output logic [63:0] o);
  logic [W-1:0] pw;                  // namesake whose width is PARAMETERIZED
  if (1) begin : g
    logic [31:0] pw;
    logic [31:0] up;                 // namesake lives in the ANCESTOR body
    logic [31:0] hid;                // namesake lives in an ancestor GEN block
    assign pw  = C.n;
    assign up  = C.n;
    assign hid = C.n;
  end
  assign o = {32'd0, g.pw} ^ {32'd0, g.up} ^ {32'd0, g.hid};
  assign pw = '0;
endmodule

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [63:0] o);
  logic [11:0] up;                   // the ancestor-body namesake, 12 bits
  logic [63:0] s1, s2;
  leaf #(.C(CFG), .W(8))  u8  (.o(s1));
  leaf #(.C(CFG), .W(40)) u40 (.o(s2));
  if (1) begin : anc
    logic [5:0] hid;                 // ancestor GEN-scope namesake: NOT searched
    assign hid = 6'd0;
  end
  assign o = s1 ^ s2 ^ {32'd0, anc.hid};
  assign up = 12'd0;
endmodule
