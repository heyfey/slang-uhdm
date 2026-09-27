// § genLocalEnumConstShared184 (control): a PACKAGE enum whose variable is declared in the generate block
package pk;
  typedef enum logic [1:0] {S0, S1, S2} st_e;
endpackage
module dut #(parameter bit P = 1'b1) (input logic clk, output logic [1:0] y);
  import pk::*;
  if (P) begin : g
    st_e q;
    always_ff @(posedge clk) begin
      if (q == S0) q <= S1; else q <= S0;
      y <= (q == S2) ? 2'd1 : 2'd0;
    end
  end
endmodule
