// § ndaConstRhsFreshLhs271
package pk;
  localparam logic [7:0] PV = 8'hC3;
endpackage
module sub (output logic [7:0] o);
  wire [3:0] w_ps = pk::PV[7:4];
  wire w_bs = pk::PV[0];
  assign o = {w_ps, 3'b0, w_bs};
endmodule
module dut (output logic [7:0] o);
  sub u_s (.o(o));
endmodule
