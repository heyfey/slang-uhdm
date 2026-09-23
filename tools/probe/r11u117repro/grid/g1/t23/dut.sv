// default: key in the pattern + module localparam qualified select
package q2;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ v: 12'h123, default: '0 };
endpackage
module top(output logic [11:0] o);
  localparam logic [11:0] V = q2::IMPL.v;
  assign o = V;
endmodule
