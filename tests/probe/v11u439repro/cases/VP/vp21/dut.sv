// § uninstProgBodyAsUninstIface439
program prg;
typedef struct { int arr[3]; } s_t;
s_t s;
initial foreach (s.arr[i]) s.arr[i] = i;
endprogram
