// § caLvTrailIdxNamesByPath264
package pk;
  localparam int I = 2;
endpackage
module top(input logic [3:0] a, output logic [3:0] o);
  typedef struct packed { logic [3:0] en; } w_t;
  w_t w;
  assign w.en[pk::I] = a[0];
  assign w.en[pk::I+1] = a[1];
  assign w.en[1:0] = a[3:2];
  assign o = w.en;
endmodule
