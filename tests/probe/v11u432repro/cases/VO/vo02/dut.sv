// § unitOobBodyArgRefUnbound432
class C;
int arr[4];
extern function int f();
endclass
function int C::f();
int s = 0;
foreach (arr[k]) s += arr[k];
return s;
endfunction
