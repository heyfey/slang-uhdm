// § caFnArgConcatFormalTs431
module top(input [11:0] a, output [3:0] y);
assign y = f({a[8:6], a[11:9]});
function [3:0] f;
input [5:0] b;
begin
  f = b[3:0];
end
endfunction
endmodule
