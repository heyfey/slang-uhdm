// face-2 qualified break: pk::P = f(3), read in a case item
package pk;
  function automatic logic [7:0] f(input int a); return a+1; endfunction
  parameter logic [7:0] P = f(3);
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
