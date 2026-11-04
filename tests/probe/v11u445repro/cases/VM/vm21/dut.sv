// § foreachLoopVarModParamTs445
module top;
parameter int i = 2;
int arr[4]; int s;
class C; int a[2]; constraint c { foreach (a[i]) a[i] < i; } endclass
endmodule
