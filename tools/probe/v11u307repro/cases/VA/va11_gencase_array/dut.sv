// § genScopeModArrayElems307
module leaf (input logic i, output logic o); assign o = ~i; endmodule
module dut #(parameter int P = 1) (input logic [1:0] a, output logic [1:0] y);
  case (P)
    1: begin : c1
      leaf u_l [1:0] (.i(a), .o(y));
    end
    default: begin : cd
      assign y = a;
    end
  endcase
endmodule
