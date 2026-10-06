// § ndaConstRhsFreshLhs271
package pk;
  localparam int PQ = 6;
  localparam logic [7:0] PH = 8'hA5;
endpackage
module sub (output logic [31:0] o);
  wire [31:0] w_p = pk::PQ;
  wire [7:0] w_h = pk::PH;
  assign o = w_p ^ w_h;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
