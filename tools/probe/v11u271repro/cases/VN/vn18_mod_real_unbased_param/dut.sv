// § ndaConstRhsFreshLhs271
package pk;
  localparam real RP = 2.5;
  localparam logic [7:0] UO = '1;
  localparam bit [3:0] BQ = 4'b1010;
endpackage
module sub (output logic [31:0] o);
  wire [31:0] w_r = pk::RP;
  wire [7:0] w_u = pk::UO;
  wire [7:0] w_b = pk::BQ;
  assign o = w_r ^ {w_u, w_b, 16'b0};
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
