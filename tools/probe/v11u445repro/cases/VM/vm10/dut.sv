// § foreachLoopVarModParamTs445
package pk; parameter int i = 7; endpackage
module top;
import pk::i;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule
