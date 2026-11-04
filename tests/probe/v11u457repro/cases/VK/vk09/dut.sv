// § pkgRetCallSharesConstRet457
function int rep(int v); return 3; endfunction
function int f(int a);
  return rep(a);
endfunction
module top;
  int x;
  initial x = f(2);
endmodule
