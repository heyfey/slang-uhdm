// parameter leaf with an unsized initializer (logic [7:0] P = 90)
package q2;
  localparam logic [7:0] P = 90;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, v: {4'h1, P}, cfg: 2'b11 };
endpackage
module top(output logic o);
  assign o = 1'b0;
endmodule
