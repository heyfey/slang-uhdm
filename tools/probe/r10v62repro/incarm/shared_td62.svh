typedef enum logic [1:0] { SA, SB, SC } sh_e;
typedef struct packed { sh_e op; logic [1:0] sz; } sh_t;
