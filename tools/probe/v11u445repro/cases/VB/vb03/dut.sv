// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
typedef struct packed { logic [1:0] f; } st_t;
initial begin st_t i; foreach (arr[i]) arr[i] = i; end
endmodule
