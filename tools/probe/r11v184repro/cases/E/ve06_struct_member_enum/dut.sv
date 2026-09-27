// § genLocalEnumConstShared184 (control): a block variable of a struct type holding a module enum member, and a module enum unpacked array
module dut #(parameter bit P = 1'b1) (input logic clk, output logic y, output logic z);
  typedef enum logic [1:0] {K0, K1, K2} k_e;
  typedef struct packed { k_e k; logic b; } ks_t;
  if (P) begin : g
    ks_t sv;
    k_e ua [2];
    always_ff @(posedge clk) begin
      sv.k <= K1;
      ua[0] <= K2;
    end
    always_comb begin
      y = (sv.k == K1);
      z = (ua[0] == K0);
    end
  end
endmodule
