// § uninstProgBodyAsUninstIface439
program prg;
typedef enum {A, B} e_t;
e_t e;
int n;
initial begin e = B; n = int'(e); case (e) A: n = 1; B: n = 2; endcase end
endprogram
