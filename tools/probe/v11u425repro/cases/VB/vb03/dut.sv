// § oneTickUpperBNormalized425
module top(input logic a, input logic b, output logic y, output logic z);
  always_comb begin
    case (a)
      1'B1: y = 1'B0;
      1'B0: y = 1'B1;
      default: y = 1'Bx;
    endcase
  end
  assign z = b ? 1'B1 : 1'B0;
endmodule
