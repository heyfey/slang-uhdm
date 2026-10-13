// § genSysArgInnerUnbound317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter P = 2) (input logic [3:0] ck, input logic [1:0] k, input logic [2:0] s, input logic [1:0][1:0] m, input logic a, output logic o);
  case (P)
    2: begin : c
      ifc u (.clk($signed(ck[s[1:0]] ^ a)));
      assign o = u.sig[0];
    end
    default: begin : d
      assign o = a;
    end
  endcase
endmodule
