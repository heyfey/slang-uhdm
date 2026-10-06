// § ndaConstRhsFreshLhs271
interface ifc (input logic [7:0] p);
  wire w_in = p inside {8'd1, [8'd5:8'd6]};
endinterface
module dut (input logic [7:0] p, output logic o);
  ifc u_if (.p(p));
  assign o = u_if.w_in;
endmodule
