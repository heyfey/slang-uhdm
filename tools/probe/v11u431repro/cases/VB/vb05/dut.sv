// § unitParamNameBindsDesign431 (a case item and an if condition)
localparam CF = 2;
module top(input [3:0] c, output logic y);
localparam CF = 1;
always_comb begin
  case (c)
    CF: y = 1;
    default: y = 0;
  endcase
  if (c == CF) y = ~y;
end
endmodule
