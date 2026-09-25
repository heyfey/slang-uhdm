// § builtinMethodArgNamedByPath154
package pk;
  function automatic int f(string a, string b);
    return a.icompare(b);
  endfunction
endpackage
module top; int r; initial r = pk::f("A", "a"); endmodule
