// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
typedef logic [3:0] n_t;
initial begin n_t i; foreach (arr[i]) arr[i] = i; end
endmodule
