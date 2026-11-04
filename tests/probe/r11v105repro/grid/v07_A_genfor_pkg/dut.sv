// break: late namesake top with a package import, a function, a generate-for of a ported leaf
package pk; typedef logic [3:0] nib_t; function automatic nib_t inc(nib_t v); return v + 1; endfunction endpackage
module leaf #(parameter int W = 2) (input logic [W-1:0] c, output logic [W-1:0] d); assign d = ~c; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod import pk::*; (input nib_t a, output nib_t b);
  logic [1:0] q [2];
  for (genvar i = 0; i < 2; i++) begin : g
    leaf #(.W(2)) u_l (.c(a[2*i+:2]), .d(q[i]));
  end
  assign b = inc({q[1], q[0]});
endmodule
