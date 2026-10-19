// § unitBoundedQTd410
typedef enum logic [1:0] {A, B} e_t;
typedef e_t q_t[$:3];
typedef real r_t;
typedef r_t rq_t[$:3];
module top; q_t a; rq_t b; endmodule
