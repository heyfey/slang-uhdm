// § caDelayNameRefKeepsOperand289v
package pk;
  typedef struct packed { logic [3:0] n; logic [7:0] m; logic [11:0] w; } s_t;
  localparam s_t K = '{n: 4'h6, m: 8'b1100_0011, w: 12'h5A3};
endpackage
module top import pk::*; #(parameter int D = 3) (output logic [3:0] o);
  if (1) begin : g
    assign #D o = K.w;
  end
endmodule
