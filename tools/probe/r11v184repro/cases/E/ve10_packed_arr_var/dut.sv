// § genLocalEnumConstShared184 (control): a generate block's packed array of a module enum and a net of the enum
module dut #(parameter bit P = 1'b1) (input logic clk, output logic y, output logic z);
  typedef enum logic [1:0] {M0, M1, M2} m_e;
  if (P) begin : g
    m_e [1:0] pa;
    wire m_e w = M1;
    always_ff @(posedge clk) pa[0] <= M1;
    always_comb begin
      y = (pa[0] == M2);
      z = (w == M0);
    end
  end
endmodule
