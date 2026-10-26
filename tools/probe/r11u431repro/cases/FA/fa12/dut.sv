// § caFnArgConcatFormalTs431 (control: a package function)
package p;
function automatic [3:0] f(input [5:0] b);
  f = b[3:0];
endfunction
endpackage
module top(input [2:0] a, input [2:0] c, output [3:0] y);
assign y = p::f({a, c});
endmodule
