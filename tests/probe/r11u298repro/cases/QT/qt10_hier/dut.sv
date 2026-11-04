// § pkgQualBoundSpanTernary298
// a ternary bound on a struct member select
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top (input logic [31:0] d, output logic [31:0] y);
  typedef struct packed { logic [31:0] f; } s_t;
  s_t s;
  assign s.f = d;
  always_comb y = 32'(s.f[(pk::DC ? pk::DC : pk::N)-1:0]);
endmodule
