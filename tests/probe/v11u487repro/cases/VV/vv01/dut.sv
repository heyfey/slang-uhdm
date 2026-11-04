// § caFoldValueFollowsPa487
typedef enum {E0, E1, E2} e_t;
module m (output logic [7:0] o); localparam W = $bits(e_t); assign o = W; endmodule
module top; logic [7:0] o; m u(o); endmodule
