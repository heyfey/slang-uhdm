// § defConnIpsFoldTsOwner236 — indexed part selects in port connections inside a generate (the law abstains) and to an instance array
package pk;
  localparam int W = 4;
  localparam int B = 2;
endpackage
module sub import pk::*; (input logic [W-1:0] a_i, output logic o);
  assign o = ^a_i;
endmodule
module mid import pk::*; (input logic [15:0] x, output logic [2:0] o);
  if (1) begin : g
    sub u_g (.a_i(x[B +: W]), .o(o[0]));
  end
  sub u_a [1:0] (.a_i(x[W +: 2*W]), .o(o[2:1]));
endmodule
module top (input logic [15:0] x, output logic [2:0] o);
  mid u_m (.x(x), .o(o));
endmodule
