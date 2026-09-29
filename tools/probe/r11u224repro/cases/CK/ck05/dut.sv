// § strLitContOwnerEnd224
module top(input logic c, output string o);
  function string f(input logic x);
    return x ? "x" : "ab \
cd";
  endfunction
  assign o = f(c);
endmodule
