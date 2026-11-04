// § genCaStructParamTypedLhsShares289
package pk;
  typedef struct packed { logic [3:0] n; logic [7:0] m; logic [11:0] w; } s_t;
  localparam s_t K = '{n: 4'h6, m: 8'b1100_0011, w: 12'h5A3};
endpackage
interface ifc ();
  import pk::*;
  logic [3:0] e;
  if (1) begin : g
    assign e = K.w;
  end
endinterface
module dut (output logic [3:0] p);
  ifc u_a ();
  assign p = u_a.e;
endmodule
