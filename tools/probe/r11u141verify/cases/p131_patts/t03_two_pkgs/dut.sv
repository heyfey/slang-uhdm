// § pkgPatReadTsNoParent131
// case t03: two packages each with a pattern parameter, both read qualified in one module
package pa;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  parameter s_t P = '{a: 4'd1, b: 4'd2};
endpackage
package pb;
  typedef struct packed { logic [1:0] c; logic [5:0] d; } s_t;
  parameter s_t Q = '{c: 2'd1, d: 6'd9};
endpackage
module top(output logic [15:0] y);
  assign y = {pa::P, pb::Q};
endmodule
