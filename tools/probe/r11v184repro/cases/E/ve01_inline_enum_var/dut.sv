// § genLocalEnumConstShared184: a generate block's variable typed by an INLINE enum, and a packed array of a module enum
module dut #(parameter bit P = 1'b1) (input logic clk, output logic [1:0] y, output logic z);
  typedef enum logic [1:0] {M0, M1, M2} m_e;
  if (P) begin : g
    enum logic [1:0] {X0, X1, X2} st;
    m_e [1:0] pa;
    always_ff @(posedge clk) begin
      st <= (st == X0) ? X1 : X2;
      pa[0] <= M1;
    end
    always_comb begin
      y = (st == X2) ? 2'd3 : 2'd0;
      z = (pa[0] == M2);
    end
  end
endmodule
