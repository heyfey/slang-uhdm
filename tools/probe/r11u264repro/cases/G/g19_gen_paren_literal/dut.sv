// § memberIpsParenEnd264
package tp;
  typedef struct packed { logic v; logic [7:0] a_source; } h2d_t;
endpackage
module top (input tp::h2d_t [1:0] h, input tp::h2d_t d, output logic [7:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = {h[i].a_source[0 +: (3)], d.a_source[(i) +: (2)], 3'b0};
  end
endmodule
