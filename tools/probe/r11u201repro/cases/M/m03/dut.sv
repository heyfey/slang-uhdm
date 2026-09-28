// § methodArgNestedRefChain201
class D;
  string s; string args[$];
  function void g(int i);
    s = s.substr(i, args[i].len() - 1);
    s = s.substr(0, args[i + 1].len());
  endfunction
endclass
module top; endmodule
