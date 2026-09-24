module top (input logic [31:0] a, input logic [4:0] s,
            output logic [31:0] o2, output logic [31:0] o3);
  case (1)
    1: begin : gc
      logic [31:0] cv;
      assign cv = a & 32'hff;
    end
  endcase
  assign o2 = a;
endmodule
