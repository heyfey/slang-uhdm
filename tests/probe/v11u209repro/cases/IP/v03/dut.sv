// § defGenTargetIpsDefName205: an indexed part select target and a part select target of one interface member in a case-generate
interface bif;
  logic [7:0] d;
endinterface
module dut #(parameter int M = 0) (input logic [3:0] x, output logic [7:0] o);
  bif b();
  case (M)
    0: begin : c0
      assign b.d[7-:4] = x;
      assign b.d[3:0] = x;
    end
    default: begin : cd
      assign b.d = '0;
    end
  endcase
  assign o = b.d;
endmodule
