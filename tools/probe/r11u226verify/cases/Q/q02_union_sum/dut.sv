// § modStructMemberQualSpan214 — a qualified bound built from two qualified names and a qualified name inside $clog2 in a module struct
package cfg;
  localparam int A = 3;
  localparam int B = 4;
  localparam int D = 16;
endpackage
module m(output logic [31:0] o);
  typedef struct packed {
    logic [cfg::A+cfg::B-1:0]   x;
    logic [$clog2(cfg::D)-1:0] y;
    logic [cfg::B:cfg::A]      z;
  } s_t;
  s_t r;
  assign r = '1;
  assign o = 32'(r);
endmodule
module top(output logic [31:0] o);
  m u(.o(o));
endmodule
