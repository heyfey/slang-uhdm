// § structParamPathBaseAtMember137
package pk;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } st_t;
endpackage
module top import pk::*; #(parameter st_t PS = '{8'd1, 8'd2})
  (input logic [31:0] a, output logic [31:0] o);
  if (1) begin : gb
    assign o = (PS.x == 8'd1) ? 32'd7 : '0;
  end
endmodule
