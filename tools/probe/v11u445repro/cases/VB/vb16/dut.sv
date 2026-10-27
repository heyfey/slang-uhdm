// § foreachLoopVarShadowDeclTs445
function automatic int uf();
  int arr[4]; int s;
  begin int i; foreach (arr[i]) s = s + i; end
  return s;
endfunction
module top; int x; initial x = uf(); endmodule
