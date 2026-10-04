// § defAggParamBindsImportClone232
// a bare packed union and a bare struct, beside a qualified one; two instances, one defaulted; a for-generate instance
package p;
  typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } s_t;
  localparam s_t SC = '{x: 4'd3, y: 4'd9};
endpackage
module child import p::*; #(parameter u_t U = '0, parameter s_t S = SC, parameter p::s_t Q = '1) (output logic [7:0] o);
  assign o = U.a ^ S ^ Q;
endmodule
module top(output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3 [2]);
  child #(.U(8'h5A), .S('{x: 4'd1, y: 4'd2})) c1 (.o(o1));
  child c2 (.o(o2));
  for (genvar i = 0; i < 2; i++) begin : g
    child #(.S(p::SC)) c (.o(o3[i]));
  end
endmodule
