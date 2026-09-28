// § genScopeClassVarListed206 (arrays of class handles: fixed, dynamic, queue, beside a scalar)
class c; int x; endclass
module v07 ();
  if (1) begin : g
    c fa [2];
    c da [];
    c qa [$];
    c s;
  end
endmodule
