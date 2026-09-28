// § importNetTsToInitEnd183: imported package variables with multi-line initializers: a packed struct with an assignment pattern, an int with an expression, a logic vector with a concatenation (wildcard import in a module)
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t cfg = '{a: 4'd1,
              b: 4'd2};
  int lim = 3 +
            4;
  logic [7:0] pat = {4'hA,
                     4'h5};
endpackage
module top (output logic [7:0] o);
  import p::*;
  assign o = cfg ^ pat ^ 8'(lim);
endmodule
