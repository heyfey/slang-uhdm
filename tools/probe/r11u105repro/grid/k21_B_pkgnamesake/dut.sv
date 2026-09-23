// golden grid: a PACKAGE innermod beside a nested module innermod (separate namespace)
package innermod; parameter int K = 3; endpackage
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = innermod::K;
endmodule
