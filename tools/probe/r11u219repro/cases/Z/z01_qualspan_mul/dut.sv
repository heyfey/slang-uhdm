// § modStructMemberQualSpan214 — a module-local struct member range with a bare package-qualified bound and a product
package cfg;
  localparam int W = 4;
  localparam int K = 2;
endpackage
module m(output logic [15:0] o);
  typedef struct packed {
    logic [cfg::W:0]      a;
    logic [cfg::K*2-1:0]  b;
  } s_t;
  s_t r;
  assign r = '1;
  assign o = 16'(r);
endmodule
module top(output logic [15:0] o);
  m u(.o(o));
endmodule
