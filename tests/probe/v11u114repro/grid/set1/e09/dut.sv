// explicit import of P only, plus a program-less nested begin/fork
package pk; parameter logic [7:0] P = {4'h7, 4'h3}; endpackage
module top (input logic [7:0] x, output logic [3:0] y);
  import pk::P;
  always_comb begin : blk
    begin
      unique case (x) P, 8'h00: y = 4'd1; default: y = 4'd0; endcase
    end
  end
endmodule
