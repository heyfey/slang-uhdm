// § pkgElemMemberPatNoLoc152
typedef struct packed { logic a; logic b; } cf_t;
typedef union packed {
  cf_t [3:0][7:0] at;
} tf_t;
module top(input tf_t a, output tf_t b);
  assign b = a;
endmodule
