// § genLocalEnumConstShared184 (control): a compilation-unit enum and a same-file package enum read in a generate block without a block variable
package p;
  typedef enum logic [1:0] {P0, P1, P2} p_e;
endpackage
typedef enum logic [1:0] {U0, U1, U2} u_e;
module dut import p::*; #(parameter bit P = 1'b1) (input logic clk, output logic y, output logic z);
  u_e mq;
  p_e pq;
  if (P) begin : g
    always_ff @(posedge clk) begin
      mq <= U1;
      pq <= P2;
    end
    always_comb begin
      y = (mq == U0);
      z = (pq == P1);
    end
  end
endmodule
