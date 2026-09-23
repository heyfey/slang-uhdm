// golden grid control for k21: the same package, NO nested namesake
package innermod; parameter int K = 3; endpackage
module sub ();
  wire [7:0] n = 8'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = innermod::K;
endmodule
