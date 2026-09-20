// v11u66 adversarial arm a5 — THE NESTED PATTERN AND THE ARRAY MEMBER.
// The flat op75 walk has a nested-pattern bail (`nestBailK`).  Where the
// producer keeps a tagged_pattern TREE and our walk flattens anyway, the law
// re-spells bytes inside a shape golden does not have — exactly the face the
// implementer fenced for `ifaceArrayDefFold`.  Does the SAME failure occur
// on the nested-struct and array-member roads of the packed mint?
package qa5;
  localparam int K = 6;
  typedef struct packed { logic [31:0] x; logic [31:0] y; } in5_t;
  typedef struct packed { in5_t i; logic [31:0] z; } out5_t;
  localparam out5_t N5 = '{i: '{x: 2 - 5, y: K * 2}, z: K - 1};
  typedef struct packed { logic [1:0][31:0] v; logic [31:0] w; } arr5_t;
  localparam arr5_t A5 = '{v: '{2 - 5, K * 2}, w: K - 1};
endpackage
module a5_nest66 #(parameter qa5::out5_t C = qa5::N5,
                   parameter qa5::arr5_t D = qa5::A5)
                 (output logic [31:0] y0, output logic [31:0] y1,
                  output logic [31:0] y2, output logic [31:0] y3);
  assign y0 = C.i.x; assign y1 = C.z; assign y2 = D.v[0]; assign y3 = D.w;
endmodule
