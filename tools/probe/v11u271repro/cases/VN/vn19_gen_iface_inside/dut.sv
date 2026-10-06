// § ndaConstRhsFreshLhs271
package pk;
  localparam logic [3:0] PQ = 4'd6;
  typedef enum logic [3:0] { EA = 1, EB = 9 } e_t;
endpackage
interface ifc (input logic [3:0] p);
  import pk::*;
  wire w_in = p inside {pk::PQ, EB};
  wire [3:0] w_q = PQ;
  wire [3:0] w_b = EA;
endinterface
module dut (input logic [3:0] p, output logic [5:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u_if (.p(p));
    assign o[3*i +: 3] = {u_if.w_in, u_if.w_q[0], u_if.w_b[0]};
  end
endmodule
