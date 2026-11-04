// § tfArgScalarTdWriter223
package p;
  typedef bit [3:0] NIB;
  class c;
    NIB v;
    covergroup cg with function sample(NIB x);
      coverpoint x;
    endgroup
    function new();
      cg = new;
    endfunction
    function void s(NIB q);
      cg.sample(q);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  NIB f;
endmodule
