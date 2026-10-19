// § assocWildcardIdxRefTs412
package pk;
  int pa [*];
endpackage
interface ifc;
  int ia [*];
endinterface
module top ();
  ifc i();
  if (1) begin : g
    int ga [*];
  end
  function void f();
    int fa [*];
  endfunction
endmodule
