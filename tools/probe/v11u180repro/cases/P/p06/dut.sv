// § pkgAggTfArgCloneFollows180 (verifier: a package task formal and a later function formal; parameter copy in a child)
package p;
  typedef struct packed {
    logic [3:0] a;
    logic [3:0] b;
  } s_t;
  task automatic t1(input s_t u); endtask
  function automatic logic [7:0] f2(input s_t v); return v; endfunction
endpackage
module child #(parameter p::s_t W = '{a: 1, b: 2}) (output logic [7:0] y);
  assign y = W;
endmodule
module top(output logic [7:0] y);
  child #(.W('{a: 5, b: 6})) c(.y(y));
endmodule
