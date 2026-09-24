module top(input logic [31:0] a, output logic [31:0] o);
  case (1)
    1: begin : gb
      assign o = (1) ? 32'd7 : '0;
    end
  endcase
endmodule
