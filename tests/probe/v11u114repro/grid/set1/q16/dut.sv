// face-2 qualified break: pk::P = {4'h1, {4{1'b1}}}, read in a case item
package pk;
  
  parameter logic [7:0] P = {4'h1, {4{1'b1}}};
endpackage
module top (input logic [7:0] x, output logic [3:0] y);
  always_comb begin
    y = 4'd0;
    case (x)
      pk::P: y = 4'd1;
      8'hFF: y = 4'd2;
      default: y = 4'd7;
    endcase
  end
endmodule
