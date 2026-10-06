// § ndaConstRhsFreshLhs271
package pk;
  localparam int NEG = -3;
  localparam logic signed [7:0] SN = -8'sd5;
endpackage
module sub (output logic [15:0] o);
  wire signed [7:0] w_n = pk::NEG;
  wire signed [7:0] w_s = pk::SN;
  assign o = {w_n, w_s};
endmodule
module dut (output logic [15:0] o);
  sub u_s (.o(o));
endmodule
