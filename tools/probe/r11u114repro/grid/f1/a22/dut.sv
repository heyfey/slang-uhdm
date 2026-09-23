// parameter leaf whose declared width exceeds its literal width
package q2;
  localparam logic [11:0] P = 8'h5A;
  typedef struct packed { logic [3:0] pad; logic [15:0] v; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, v: {4'h1, P}, cfg: 2'b11 };
endpackage
module top(output logic o);
  assign o = 1'b0;
endmodule
