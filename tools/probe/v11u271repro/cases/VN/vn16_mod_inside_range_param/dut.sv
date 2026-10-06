// § ndaConstRhsFreshLhs271
module sub #(parameter logic [3:0] LO = 2, HI = 7) (input logic [3:0] a, output logic [1:0] o);
  wire w_r = a inside {[LO:HI]};
  wire w_c = 4'd5 inside {LO, HI};
  assign o = {w_r, w_c};
endmodule
module dut (input logic [3:0] a, output logic [1:0] o);
  sub #(.HI(9)) u_s (.a(a), .o(o));
endmodule
