// § modStructMemberQualSpan214 — a module-local packed union whose member range folds a package parameter
package cfg;
  localparam int W = 6;
endpackage
module top(output logic [7:0] o);
  typedef union packed {
    logic [cfg::W-1:0] a;
    logic [5:0]        b;
  } u_t;
  u_t r;
  assign r = '0;
  assign o = 8'(r);
endmodule
