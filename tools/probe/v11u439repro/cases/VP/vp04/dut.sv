// § uninstProgBodyAsUninstIface439
program prg;
typedef enum logic [1:0] {RED, GRN, BLU} col_t;
col_t c;
typedef struct packed { logic [3:0] a; logic b; } s_t;
s_t s;
initial begin c = GRN; s.a = 4'h3; s.b = s.a[0]; end
endprogram
