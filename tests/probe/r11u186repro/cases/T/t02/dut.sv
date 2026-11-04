// § typeParamUseSharesOwnTs183 (a formal written with the parameter: the law declines)
package p;
class base; endclass
class holder #(type H = base);
  function void run(H arg);
    H h1;
    h1 = arg;
  endfunction
endclass
endpackage
module top; endmodule
