// § defGenCaCommaListSpan283
module dut #(parameter int P = 1) (input logic [3:0] x, output logic [3:0] a, b);
  case (P)
    1: begin : c1
      assign a = x, b = ~x;
    end
    default: begin : cd
      assign a = 0, b = 0;
    end
  endcase
endmodule
