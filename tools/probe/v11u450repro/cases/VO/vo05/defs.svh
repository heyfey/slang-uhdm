typedef enum {RD, WR} kind_e;
typedef struct {
  kind_e kind;
  int n;
} op_s;
