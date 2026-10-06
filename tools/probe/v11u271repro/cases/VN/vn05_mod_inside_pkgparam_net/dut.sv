// § ndaConstRhsFreshLhs271
package pk;
  localparam logic [3:0] PQ = 4'd6;
endpackage
module sub (input logic [3:0] a, output logic o);
  wire w_i = a inside {pk::PQ, 4'd3};
  assign o = w_i;
endmodule
module dut (input logic [3:0] a, output logic o);
  sub u_s (.a(a), .o(o));
endmodule
