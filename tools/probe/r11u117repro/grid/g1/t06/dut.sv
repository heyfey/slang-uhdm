// ENUM elem typedef (fpnew shape) row_t[0:1], gen-loop select
package q2;
  typedef enum logic [1:0] {U0, U1, U2} ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 12'h56A, cfg: 2'b11 };
endpackage
module top(output logic [11:0] o);
  for (genvar g = 0; g < 2; g++) begin : gg
    localparam q2::row_t R = q2::IMPL.m[g];
    assign o[g*6+:6] = R;
  end
endmodule
