// § builtinMethodArgNamedByPath154
class C;
  string s;
  function int f(string t); return s.compare(t); endfunction
endclass
module top; C c = new; int b; initial b = c.f("x"); endmodule
