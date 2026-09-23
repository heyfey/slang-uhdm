// break: sub instantiates its nested innermod explicitly by a DIFFERENT instance name via a gen block; late ported top
module sub ();
  module innermod (input logic k); wire [7:0] n = {8{k}}; endmodule
  if (1) begin : gb
    logic kk = 1'b0;
  end
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b); assign b = a; endmodule
