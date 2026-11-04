// § newArrayArgPathElemsStripped200
package p;
  function automatic void f(ref int a[], input int b[], input bit c);
    a = new[c ? b.size : 2];
    a = new[(b.size + a.size)];
  endfunction
endpackage
module z02; endmodule
