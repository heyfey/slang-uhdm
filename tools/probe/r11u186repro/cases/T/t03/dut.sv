// § typeParamUseSharesOwnTs183 (nested block local)
package p;
class base; endclass
class holder #(type H = base, type G = H);
  function void run();
    begin
      H h1;
      G g1;
    end
  endfunction
endclass
endpackage
module top; endmodule
