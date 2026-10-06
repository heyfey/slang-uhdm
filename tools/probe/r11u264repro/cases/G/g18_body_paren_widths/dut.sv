// § memberIpsParenEnd264
package tp;
  typedef struct packed { logic v; logic [7:0] a_source; } h2d_t;
endpackage
module top #(parameter int W = 4) (input tp::h2d_t [1:0] h, input tp::h2d_t d, output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3, output logic [7:0] o4);
  localparam int L = 2;
  assign o1 = d.a_source[0 +: (W)];
  assign o2 = h[1].a_source[(L) +: (W - L)];
  assign o3 = d.a_source[7 -: ((W))];
  always_comb o4 = h[0].a_source[1 +: (L)];
endmodule
