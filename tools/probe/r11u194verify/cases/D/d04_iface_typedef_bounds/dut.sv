// § boundLitUnderscoreDropped186 § enumConstUnderscoreDropped186: separators in a typedef bound, a struct member bound, an interface signal bound and an interface enum value
interface sif;
  typedef enum logic [3:0] { I0 = 1_0, I1 = 1_2 } ie_t;
  logic [1_1:0] sig;
  ie_t st;
endinterface
module top;
  typedef logic [2_3:0] w_t;
  typedef struct packed { logic [1_0:0] f; w_t g; } s_t;
  s_t v;
  sif s ();
endmodule
