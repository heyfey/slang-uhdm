// § newArrayKeepFrozenBare201v
package pk;
  class C;
    int n;
    byte data[];
    function void t(C o);
      data = new[this.n + o.n];
      data = new[o.n];
    endfunction
  endclass
endpackage
module top;
  pk::C c;
  initial begin c = new; c.t(c); end
endmodule
