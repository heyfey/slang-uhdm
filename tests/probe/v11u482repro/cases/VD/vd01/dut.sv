// § cloneFixArrAggElemShared482 (downstream: cloned function with a fixed struct array in a continuous assignment)
package u;
  typedef struct packed { logic [7:0] k; logic [7:0] data; } op_t;
  function automatic logic [7:0] f(input logic [7:0] n);
    op_t acc[2];
    acc[0].k = n;
    acc[0].data = n + 8'd1;
    acc[1] = acc[0];
    return acc[1].data ^ acc[0].k;
  endfunction
endpackage
package a;
  import u::*;
  function automatic logic [7:0] g(input logic [7:0] n); return f(n); endfunction
endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  import a::*;
  assign o = g(i);
endmodule
