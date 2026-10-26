// § caFnArgConcatFormalTs431 (control: a typedef-typed packed formal)
module top(input [3:0] a, input [3:0] c, output [3:0] y);
typedef logic [3:0] word;
function automatic [3:0] f(input word [1:0] b);
  f = b[0];
endfunction
assign y = f({a, c});
endmodule
