// § tpRetOobRefVar424 (control: a class-typed parameter binding)
class D; endclass
class C #(type T = D);
  extern function T mk();
endclass
function C::T C::mk();
  return null;
endfunction
