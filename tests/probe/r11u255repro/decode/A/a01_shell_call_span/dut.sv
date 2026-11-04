// § shellCallKeepsItsSyntax167 (decode only, ground A: BuildUVMPkg d/t #194627, the Invalid-shell call hier_path spans the callee where golden spans the whole invocation)
package p;
virtual class wrap; endclass
class fac;
  function bit reg1(wrap r); return 1; endfunction
  static function fac get(); return null; endfunction
endclass
class c #(type T=int);
  static function void f1(string a);
    if (a != "") begin
      fac factory = fac::get();
      T rgtry = 3;
      if (factory.reg1(rgtry)) begin
      end
    end
  endfunction
endclass
endpackage
module top; endmodule
