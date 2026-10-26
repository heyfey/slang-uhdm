// § newLhsSelCgCopyAtIndex437
package p;
covergroup cg with function sample(int x); coverpoint x; endgroup
endpackage
class K;
  p::cg cs[2];
  function void f(); cs[0] = new; foreach (cs[i]) cs[i] = new; endfunction
endclass
module top; K k; initial begin k = new; k.f(); end endmodule
