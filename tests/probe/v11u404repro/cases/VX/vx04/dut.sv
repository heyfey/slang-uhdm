// § unitParamXzLiteral404
parameter logic [63:0] W = '1;
parameter shortint H = '1;
parameter byte Y = 'x;
parameter E = 'x;
module top;
  initial $display(W, H, Y, E);
endmodule
