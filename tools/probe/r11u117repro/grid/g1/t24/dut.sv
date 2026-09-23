// member value is a package param ref + module localparam qualified select
package q2;
  localparam logic [11:0] VV = 12'h123;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, v: VV, cfg: 2'b11 };
endpackage
module top(output logic [11:0] o);
  localparam logic [11:0] V = q2::IMPL.v;
  assign o = V;
endmodule
