// § ifSelShareConstBounds289v
package pk;
  typedef struct packed { logic [3:0] n; logic [7:0] m; logic [11:0] w; } s_t;
  localparam s_t K = '{n: 4'h6, m: 8'b1100_0011, w: 12'h5A3};
endpackage
interface ifc #(parameter int I = 2) ();
  import pk::*;
  logic [3:0] b;
  assign b[I] = K.n;
endinterface
module dut (output logic [3:0] q);
  ifc u_a ();
  assign q = u_a.b;
endmodule
