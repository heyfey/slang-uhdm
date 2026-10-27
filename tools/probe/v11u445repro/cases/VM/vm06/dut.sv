// § foreachLoopVarModParamTs445
module top;
typedef enum logic [1:0] {A, B, C} e_t;
parameter e_t i = B;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule
