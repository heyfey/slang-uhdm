// § ndaConstRhsFreshLhs271
package pk;
  localparam int PQ = 6;
  typedef enum logic [3:0] { EA = 1, EB = 9 } e_t;
endpackage
module sub #(parameter int N = 2) (output logic [31:0] o);
  import pk::*;
  wire [31:0] w_p = pk::PQ + 0;
  wire [31:0] w_q = PQ;
  wire [3:0] w_e = EB;
  assign o = w_p ^ w_q ^ w_e;
endmodule
module dut (output logic [63:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    sub #(.N(i)) u_s (.o(o[32*i +: 32]));
  end
endmodule
