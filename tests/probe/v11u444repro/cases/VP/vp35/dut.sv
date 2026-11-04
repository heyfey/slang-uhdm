// § progLocalDeclNets444
program prg;
typedef struct packed { logic [3:0] a; logic b; } s_t;
int x;
task automatic t();
  s_t s = '{default: 0};
  integer i = 3;
  logic [7:0] m [2] = '{8'h1, 8'h2};
  x = s.a + i;
endtask
initial t();
endprogram
