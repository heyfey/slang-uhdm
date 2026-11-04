// § caFoldTsFollowsPa487
typedef enum {E0, E1, E2} e_t;
module m (output logic [7:0] o); localparam B = E2; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
