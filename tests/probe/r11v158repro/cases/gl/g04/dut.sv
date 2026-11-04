// § genCaLhsEnumConstClone158
module dut #(parameter int K = 1) (input logic [7:0] a, output logic [3:0][7:0] o);
  typedef enum logic [1:0] {A, B, C, D} e_t;
  case (K)
    1: begin : c1 assign o[D] = a; end
    default: begin : cd assign o[A] = a; end
  endcase
endmodule
