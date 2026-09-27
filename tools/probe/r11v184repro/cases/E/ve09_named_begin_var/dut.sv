// § genLocalEnumConstShared184 (control): a module enum read in a generate block through a named begin's own variable only
module dut #(parameter bit P = 1'b1) (input logic clk, output logic y);
  typedef enum logic [1:0] {M0, M1, M2} m_e;
  if (P) begin : g
    always_ff @(posedge clk) begin : nb
      m_e t;
      t = M1;
      y <= (t == M2);
    end
  end
endmodule
