// face-2 qualified break: pk::P = OTHER.a, read in a case item
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } pair_t; parameter pair_t OTHER = '{a: 8'h11, b: 8'h22};
  parameter logic [7:0] P = OTHER.a;
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
