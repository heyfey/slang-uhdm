// § unitOobBodyRefChainName432
class C;
extern function int f(int a);
endclass
function int C::f(int a);
begin : outer
  int y;
  begin : inner
    int z;
    z = a;
    y = z;
  end
  return y;
end
endfunction
