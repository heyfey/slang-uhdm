// unpacked struct param + module localparam qualified select
package q2;
  typedef struct { logic [3:0] pad; logic [11:0] v; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, v: 12'h123 };
endpackage
module top(output logic [11:0] o);
  localparam logic [11:0] V = q2::IMPL.v;
  assign o = V;
endmodule
