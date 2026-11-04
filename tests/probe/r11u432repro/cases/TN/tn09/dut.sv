// § unitOobBodyRefChainName432
class C;
int q;
extern function int f(int a);
endclass
function int C::f(int a);
int x;
x = a + q;
begin : blk
  int y;
  y = x;
end
for (int i = 0; i < 2; i++) x += i;
return x;
endfunction
