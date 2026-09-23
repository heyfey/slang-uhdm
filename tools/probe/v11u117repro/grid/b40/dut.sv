// L1 + 3 generate iterations over element select into a typed localparam
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 12'h56A, cfg: 2'b11 };
endpackage
module top(output logic [17:0] o);
  for (genvar g = 0; g < 3; g++) begin : gg
    localparam q2::ut_e E = q2::IMPL.m[0][g];
    assign o[g*2+:2] = E;
  end
endmodule
