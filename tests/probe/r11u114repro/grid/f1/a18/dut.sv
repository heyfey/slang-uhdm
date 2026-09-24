// concat of two unsized-width-mismatched? no: concat with a 1-bit literal and a 64-bit? sized 40-bit + 32
package q2;
  typedef struct packed { logic [3:0] pad; logic [71:0] v; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, v: {40'h12_3456_789A, 32'hDEADBEEF}, cfg: 2'b11 };
endpackage
module top(output logic o);
  assign o = 1'b0;
endmodule
