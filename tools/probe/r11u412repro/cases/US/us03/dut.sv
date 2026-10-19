// § unpStructArrElemVar412
package pk;
  typedef struct { int a; } ps_t;
  ps_t pa [3];
endpackage
module top();
  import pk::*;
  ps_t ma [2] = '{'{1}, '{2}};
  if (1) begin : g
    ps_t ga [2];
  end
endmodule
