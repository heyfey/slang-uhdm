// § oobClassTdFirstClassKey231 — control: the method's class key is first
package p;
  class aa;
    typedef aa this_type;
    extern function void put(this_type v);
  endclass
  function void aa::put(this_type v);
  endfunction
  class zz;
    typedef zz this_type;
  endclass
endpackage
module top;
endmodule
