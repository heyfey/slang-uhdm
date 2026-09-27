// § typeParamUseSharesOwnTs183
package p;
class base; endclass
class holder #(type H = base);
  function void run();
    H h1;
    H h2;
    h1 = null;
  endfunction
  task go();
    H h3;
  endtask
endclass
endpackage
module top; endmodule
