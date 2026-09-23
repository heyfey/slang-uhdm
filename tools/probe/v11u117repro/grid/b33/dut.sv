// generate loop, direct instance override with the element select
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 12'h56A, cfg: 2'b11 };
endpackage
module leaf #(parameter q2::row_t UT = '0)(output logic [5:0] o); assign o = UT; endmodule
module top(output logic [11:0] o);
  for (genvar g = 0; g < 2; g++) begin : gg
    leaf #(.UT(q2::IMPL.m[g])) u(.o(o[g*6+:6]));
  end
endmodule
