module top #(parameter int K = 9, parameter int PBal = 1)
  (input logic [31:0] a, input logic [31:0] b, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
  case (K)
    9: begin : gc
      logic [31:0] lv;
      assign lv = '0;
    end
    default: begin : gd
      logic [31:0] lv;
      assign lv = '1;
    end
  endcase
  assign o2 = gc.lv;
endmodule
